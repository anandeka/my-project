SET DEFINE OFF;
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
          pcdi.pcdi_id;
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
          pcdi.price_option_call_off_status;
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

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('CancelWNS', 'Cancel WNS Ref No', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

BEGIN

for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 

loop

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CWNS-&'||CC.CORPORATE_ID, 'CancelWNS', CC.CORPORATE_ID, 'CANCELWNS-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CWNS-&'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_WNS_ASSAY', 'CancelWNS', 'N');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_WNS_ASSAY', 'CANCELWNS-', 0, '-'||CC.CORPORATE_ID);
 

 end loop;

end;

--Added New Coloumn TRADING_MINING_COMB_TYPE 

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30));

ALTER TABLE GMRUL_GMR_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30));

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD add (
  CONSTRAINT CHK_GMR_TRADING_MIN_COMB_TYPE
 CHECK (TRADING_MINING_COMB_TYPE IN ('Trading','Mining','Combined')));

 
 
ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE GRD_GOODS_RECORD_DETAIL add (
  CONSTRAINT CHK_GRD_TRADING_MIN_COMB_TYPE
 CHECK (TRADING_MINING_COMB_TYPE IN ('Trading','Mining','Combined')));
 
 
ALTER TABLE DGRD_DELIVERED_GRD ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRDUL_DELIVERED_GRD_UL ADD (TRADING_MINING_COMB_TYPE  VARCHAR2(30)); 

ALTER TABLE DGRD_DELIVERED_GRD add (
  CONSTRAINT CHK_DGRD_TRADING_MIN_COMB_TYPE
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
     and pfd.is_hedge_correction = 'Y';
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
-- and to_char(pfd.as_of_date, 'dd-Mon-yyyy') = '{?AsOfDate}';
/
ALTER TABLE IS_D MODIFY (GMR_REF_NO varchar2(4000));
ALTER TABLE IS_D MODIFY (STOCK_REF_NO varchar2(4000));

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

alter table HCD_HEDGE_CORRECTION_DETAILS add EVENT_SEQUENC_NO varchar(30);
alter table IS_INVOICE_SUMMARY add(INVOICE_ADJUSTMENT_AMOUNT NUMBER(25,10));
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
       (t.bl_dry_weight - t.actual_dry_weight) / t.bl_dry_weight * 100 dry_ratio
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
                  qum.qty_unit) t;
/
create or replace view v_bi_mb_recent5_by_feed as
select tt.corporate_id,
       tt.product_id,
       tt.product_name,
       tt.reference_no,
       tt.activity,
       tt.cp_id,
       tt.cpname cp_name,--Bug 63266 Fix added alias name
       tt.quantity,
       tt.base_qty_unit_id,
       tt.base_qty_unit,
       tt.internal_grd_ref_no,
       tt.created_date,
       tt.order_id
  from (select t.corporate_id,
               t.product_id,
               pdm.product_desc product_name,
               t.action_ref_no reference_no,
               axm.action_name activity,
               phd.profileid cp_id,
               phd.companyname cpname,
               t.qty quantity,
               t.qty_unit_id base_qty_unit_id,
               qum.qty_unit base_qty_unit,
               t.internal_grd_ref_no,
               t.created_date,
               row_number() over(partition by t.corporate_id, t.product_id order by t.created_date desc) order_id
          from (select grd.internal_grd_ref_no,
                       substr(max(case
                                    when gmr.corporate_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     gmr.corporate_id
                                  end),
                              24) corporate_id,
                       substr(max(case
                                    when grdul.pcdi_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     grdul.pcdi_id
                                  end),
                              24) pcdi_id,
                       substr(max(case
                                    when grdul.product_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     grdul.product_id
                                  end),
                              24) product_id,
                       substr(max(case
                                    when grdul.qty is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     grdul.qty
                                  end),
                              24) qty,
                       substr(max(case
                                    when grdul.qty_unit_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     grdul.qty_unit_id
                                  end),
                              24) qty_unit_id,
                       substr(max(case
                                    when axs.action_id is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     axs.action_id
                                  end),
                              24) action_id,
                       substr(max(case
                                    when axs.action_ref_no is not null then
                                     to_char(axs.created_date, 'yyyymmddhh24missff9') ||
                                     axs.action_ref_no
                                  end),
                              24) action_ref_no,
                       max(case
                             when axs.created_date is not null then
                              axs.created_date
                           end) created_date
                  from grdul_goods_record_detail_ul grdul,
                       grd_goods_record_detail      grd,
                       gmr_goods_movement_record    gmr,
                       axs_action_summary           axs
                 where grdul.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and grdul.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = grdul.internal_grd_ref_no
                   and grd.tolling_stock_type = 'MFT In Process Stock'
                   and gmr.is_deleted='N'--Bug 66695
                   and grd.status = 'Active'
                 group by grdul.internal_grd_ref_no,
                          grd.internal_grd_ref_no) t,
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
           and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           and pcm.cp_id = phd.profileid
           and t.qty_unit_id = qum.qty_unit_id) tt
 where tt.order_id <= 5; 
/
declare
fetchqry1 clob := 'INSERT INTO IS_D (
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
CP_NAME,
CP_ADDRESS,
CP_COUNTRY,
CP_CITY,
CP_STATE,
CP_ZIP,
CONTRACT_TYPE,
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
PHD.COMPANYNAME as CP_NAME,
PAD.ADDRESS as CP_ADDRESS,
CYM.COUNTRY_NAME as CP_COUNTRY,
CIM.CITY_NAME as CP_CITY,
SM.STATE_NAME as CP_STATE,
PAD.ZIP as CP_ZIP,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
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
PHD.COMPANYNAME,
PAD.ADDRESS,
CYM.COUNTRY_NAME,
CIM.CITY_NAME,
SM.STATE_NAME,
PAD.ZIP,
PCM.CONTRACT_TYPE,
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
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DOC_ID IN ('CREATE_FI','CREATE_DFI','CREATE_PI') AND DGM_ID IN ('10','11','12');
 commit;
  
end;

ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(TOTAL_INVOICE_AMOUNT VARCHAR2(500 CHAR));


ALTER TABLE IUD_INVOICE_UTILITY_DETAIL
MODIFY(PARENT_INVOICE_AMOUNT VARCHAR2(500 CHAR));
create or replace view v_list_of_tolling_gmr as
select gmr.corporate_id as corporate_id,
       gmr.internal_gmr_ref_no as internal_gmr_ref_no,
       gmr.qty || ' ' || pkg_general.f_get_quantity_unit(gmr.qty_unit_id) as gmr_qty_string,
       gmr.gmr_ref_no as gmr_ref_no,
       gmr.is_pass_through as is_pass_through,
       gmr.tolling_gmr_type as process_type,
       gam.action_no as action_no,
       axs.internal_action_ref_no as internal_action_ref_no,
       (select (case
                 when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
                  'Receive Material'
                 else
                  axm.action_name
               end) action_name
          from axm_action_master axm
         where axm.action_id = axs.action_id) as activity,
       axs.eff_date as activity_date,
       axs.action_ref_no as activity_ref_no,
       gmr.gmr_latest_action_action_id as latest_action_id,
       (select (case
                 when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
                  'Receive Material'
                 else
                  axm.action_name
               end) action_name
          from axm_action_master axm
         where axm.action_id = gmr.gmr_latest_action_action_id) as latest_action_name,
       gmr.warehouse_profile_id as warehouse_profile_id,
       shm.companyname as warehouse,
       shm.shed_name as shed_name,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          (select f_string_aggregate(grd_rm.product_id)
             from grd_goods_record_detail grd_rm
            where grd_rm.tolling_stock_type = 'RM Out Process Stock'
              and grd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         when axm.action_id = 'CREATE_RETURN_MATERIAL' then
          (select f_string_aggregate(dgrd_rm.product_id)
             from dgrd_delivered_grd dgrd_rm
            where dgrd_rm.tolling_stock_type = 'Return Material Stock'
              and dgrd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         else
          cp.product_id
       end) as product_id,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          (select f_string_aggregate(pdm_in.product_desc)
             from grd_goods_record_detail grd_rm,
                  pdm_productmaster       pdm_in
            where pdm_in.product_id = grd_rm.product_id
              and grd_rm.tolling_stock_type = 'RM Out Process Stock'
              and grd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         when axm.action_id = 'CREATE_RETURN_MATERIAL' then
          (select f_string_aggregate(pdm_in.product_desc)
             from dgrd_delivered_grd dgrd_rm,
                  pdm_productmaster  pdm_in
            where pdm_in.product_id = dgrd_rm.product_id
              and dgrd_rm.tolling_stock_type = 'Return Material Stock'
              and dgrd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         else
          cp.product_name
       end) as product_name,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          (select f_string_aggregate(grd_rm.quality_id)
             from grd_goods_record_detail grd_rm
            where grd_rm.tolling_stock_type = 'RM Out Process Stock'
              and grd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         when axm.action_id = 'CREATE_RETURN_MATERIAL' then
          (select f_string_aggregate(dgrd_rm.quality_id)
             from dgrd_delivered_grd dgrd_rm
            where dgrd_rm.tolling_stock_type = 'Return Material Stock'
              and dgrd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         else
          cp.quality_id
       end) as quality_id,
       (case
         when axm.action_id = 'RECORD_OUT_PUT_TOLLING' then
          (select f_string_aggregate(qat_in.quality_name)
             from grd_goods_record_detail grd_rm,
                  qat_quality_attributes  qat_in
            where qat_in.quality_id = grd_rm.quality_id
              and grd_rm.tolling_stock_type = 'RM Out Process Stock'
              and grd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         when axm.action_id = 'CREATE_RETURN_MATERIAL' then
          (select f_string_aggregate(qat_in.quality_name)
             from dgrd_delivered_grd     dgrd_rm,
                  qat_quality_attributes qat_in
            where qat_in.quality_id = dgrd_rm.quality_id
              and dgrd_rm.tolling_stock_type = 'Return Material Stock'
              and dgrd_rm.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
         else
          cp.quality_name
       end) as quality_name,
       gmr.qty as gmr_qty,
       gmr.qty_unit_id as qty_unit_id,
       pkg_general.f_get_quantity_unit(gmr.qty_unit_id) as qty_unit,
       wrd.smelter_cp_id as cp_profile_id,
       phd_cp.companyname as cp_name,
       cp.price_allocation_method as price_allocation_method,
       cp.internal_contract_item_ref_no as internal_contract_item_ref_no,
       cp.contract_item_ref_no as contract_item_ref_no,
       cp.internal_contract_ref_no as internal_contract_ref_no,
       cp.contract_ref_no as contract_ref_no,
       (case
         when (select distinct grd.internal_gmr_ref_no
                 from grd_goods_record_detail grd
                where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
                  and grd.tolling_stock_type = 'Free Material Stock'
                  and grd.status = 'Active') is not null then
          'Y'
         else
          'N'
       end) is_free_material,
       cp.pcdi_id pcdi_id,
       cp.deliveryitemrefno as delivery_item_ref_no,
       wrd.feeding_point_id,
       sfp.feeding_point_name,
       axs.created_date,
       (select aku_sub.login_name
          from ak_corporate_user aku_sub
         where aku_sub.user_id = axs.created_by) created_by,
       axs_last.updated_date,
       (select aku_sub.login_name
          from ak_corporate_user aku_sub
         where aku_sub.user_id = axs_last.created_by) updated_by
  from gmr_goods_movement_record gmr,
       gam_gmr_action_mapping gam,
       axs_action_summary axs,
       axm_action_master axm,
       axs_action_summary axs_last,
       v_shm_shed_master shm,
       (select f_string_aggregate(pci.internal_contract_ref_no) internal_contract_ref_no,
               f_string_aggregate(pci.contract_ref_no) contract_ref_no,
               f_string_aggregate(pci.internal_contract_item_ref_no) internal_contract_item_ref_no,
               f_string_aggregate(pci.contract_item_ref_no) contract_item_ref_no,
               f_string_aggregate(pci.product_id) product_id,
               f_string_aggregate(pci.product_name) product_name,
               f_string_aggregate(pci.quality_id) quality_id,
               f_string_aggregate(pci.quality_name) quality_name,
               f_string_aggregate(gcim.internal_gmr_ref_no) internal_gmr_ref_no,
               pci.price_allocation_method as price_allocation_method,
               f_string_aggregate(pci.pcdi_id) pcdi_id,
               f_string_aggregate(pci.delivery_item_ref_no) deliveryitemrefno
          from v_pci                          pci,
               gcim_gmr_contract_item_mapping gcim
         where pci.internal_contract_item_ref_no =
               gcim.internal_contract_item_ref_no
         group by gcim.internal_gmr_ref_no,
                  pci.price_allocation_method) cp,
       wrd_warehouse_receipt_detail wrd,
       phd_profileheaderdetails phd_cp,
       sfp_smelter_feeding_point sfp
 where gmr.internal_gmr_ref_no = wrd.internal_gmr_ref_no
   and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
   and gmr.is_deleted = 'N'
   and wrd.warehouse_profile_id = shm.profile_id(+)
   and wrd.shed_id = shm.shed_id(+)
   and phd_cp.profileid = wrd.smelter_cp_id
   and sfp.feeding_point_id(+) = wrd.feeding_point_id
   and gmr.internal_gmr_ref_no = cp.internal_gmr_ref_no(+)
   and nvl(gmr.tolling_gmr_type, 'None Tolling') in
       ('Mark For Tolling', 'Received Materials', 'Return Material')
   and axs_last.internal_action_ref_no = gmr.internal_action_ref_no;
/
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG ADD
(
SUPP_INTERNAL_GMR_REF_NO VARCHAR2 (15)
);
create or replace trigger "TRG_INSERT_GRDL"
/**************************************************************************************************
           Trigger Name                       : trg_insert_grdl
           Author                             : Mohit
           Created Date                       : 20th May 2011
           Purpose                            : To Insert into GRDL Table

           Modification History

           Modified Date  :
           Modified By  :
           Modify Description :

   ***************************************************************************************************/
  after insert or update on grd_goods_record_detail
  for each row
begin
  --
  -- If updating then put the delta for Quantity columns as Old - New when GRD is Active
  -- If GRD is inactive then negate all the quantity columns
  -- If inserting put the new value as is as Delta
  --
  if updating then
    if :new.is_deleted = 'N' then
      --Qty Unit is Not Updated
      if :new.qty_unit_id = :old.qty_unit_id then
        insert into grdl_goods_record_detail_log
          (internal_grd_ref_no,
           internal_gmr_ref_no,
           product_id,
           is_afloat,
           status,
           qty_delta,
           qty_unit_id,
           gross_weight_delta,
           tare_weight_delta,
           internal_contract_item_ref_no,
           int_alloc_group_id,
           packing_size_id,
           container_no,
           seal_no,
           mark_no,
           warehouse_ref_no,
           no_of_units_delta,
           quality_id,
           warehouse_profile_id,
           shed_id,
           origin_id,
           crop_year_id,
           parent_id,
           is_released_shipped,
           release_shipped_no_units_delta,
           is_write_off,
           write_off_no_of_units_delta,
           is_moved_out,
           moved_out_no_of_units_delta,
           total_no_of_units_delta,
           total_qty_delta,
           moved_out_qty_delta,
           release_shipped_qty_delta,
           write_off_qty_delta,
           title_transfer_out_qty_delta,
           title_transfr_out_no_unt_delta,
           warehouse_receipt_no,
           warehouse_receipt_date,
           container_size,
           remarks,
           is_added_to_pool,
           loading_date,
           loading_country_id,
           loading_port_id,
           is_entire_item_loaded,
           is_weight_final,
           bl_number,
           bl_date,
           parent_internal_grd_ref_no,
           discharged_qty_delta,
           is_voyage_stock,
           allocated_qty_delta,
           internal_stock_ref_no,
           landed_no_of_units_delta,
           landed_net_qty_delta,
           landed_gross_qty_delta,
           shipped_no_of_units_delta,
           shipped_net_qty_delta,
           shipped_gross_qty_delta,
           current_qty_delta,
           stock_status,
           product_specs,
           source_type,
           source_int_stock_ref_no,
           source_int_purchase_ref_no,
           source_int_pool_ref_no,
           is_fulfilled,
           inventory_status,
           truck_rail_number,
           truck_rail_type,
           packing_type_id,
           handled_as,
           allocated_no_of_units_delta,
           current_no_of_units_delta,
           stock_condition,
           gravity_type_id,
           gravity_delta,
           density_mass_qty_unit_id,
           density_volume_qty_unit_id,
           gravity_type,
           customs_id,
           tax_id,
           duty_id,
           customer_seal_no,
           brand,
           no_of_containers_delta,
           no_of_bags_delta,
           no_of_pieces_delta,
           rail_car_no,
           sdcts_id,
           partnership_type,
           is_trans_ship,
           is_mark_for_tolling,
           tolling_qty,
           tolling_stock_type,
           element_id,
           expected_sales_ccy,
           profit_center_id,
           strategy_id,
           is_warrant,
           warrant_no,
           pcdi_id,
           supp_contract_item_ref_no,
           supplier_pcdi_id,
           supp_internal_gmr_ref_no,
           utility_header_id,
           payable_returnable_type,
           carry_over_qty,
           internal_action_ref_no,
           entry_type,
           is_deleted)
        values
          (:new.internal_grd_ref_no,
           :new.internal_gmr_ref_no,
           :new.product_id,
           :new.is_afloat,
           :new.status,
           :new.qty - :old.qty,
           :new.qty_unit_id,
           :new.gross_weight - :old.gross_weight,
           :new.tare_weight - :old.tare_weight,
           :new.internal_contract_item_ref_no,
           :new.int_alloc_group_id,
           :new.packing_size_id,
           :new.container_no,
           :new.seal_no,
           :new.mark_no,
           :new.warehouse_ref_no,
           :new.no_of_units - :old.no_of_units,
           :new.quality_id,
           :new.warehouse_profile_id,
           :new.shed_id,
           :new.origin_id,
           :new.crop_year_id,
           :new.parent_id,
           :new.is_released_shipped,
           :new.release_shipped_no_of_units -
           :old.release_shipped_no_of_units,
           :new.is_write_off,
           :new.write_off_no_of_units - :old.write_off_no_of_units,
           :new.is_moved_out,
           :new.moved_out_no_of_units - :old.moved_out_no_of_units,
           :new.total_no_of_units - :old.total_no_of_units,
           :new.total_qty - :old.total_qty,
           :new.moved_out_qty - :old.moved_out_qty,
           :new.release_shipped_qty - :old.release_shipped_qty,
           :new.write_off_qty - :old.write_off_qty,
           :new.title_transfer_out_qty - :old.title_transfer_out_qty,
           :new.title_transfer_out_no_of_units -
           :old.title_transfer_out_no_of_units,
           :new.warehouse_receipt_no,
           :new.warehouse_receipt_date,
           :new.container_size,
           :new.remarks,
           :new.is_added_to_pool,
           :new.loading_date,
           :new.loading_country_id,
           :new.loading_port_id,
           :new.is_entire_item_loaded,
           :new.is_weight_final,
           :new.bl_number,
           :new.bl_date,
           :new.parent_internal_grd_ref_no,
           :new.discharged_qty - :old.discharged_qty,
           :new.is_voyage_stock,
           :new.allocated_qty - :old.allocated_qty,
           :new.internal_stock_ref_no,
           :new.landed_no_of_units - :old.landed_no_of_units,
           :new.landed_net_qty - :old.landed_net_qty,
           :new.landed_gross_qty - :old.landed_gross_qty,
           :new.shipped_no_of_units - :old.shipped_no_of_units,
           :new.shipped_net_qty - :old.shipped_net_qty,
           :new.shipped_gross_qty - :old.shipped_gross_qty,
           :new.current_qty - :old.current_qty,
           :new.stock_status,
           :new.product_specs,
           :new.source_type,
           :new.source_int_stock_ref_no,
           :new.source_int_purchase_ref_no,
           :new.source_int_pool_ref_no,
           :new.is_fulfilled,
           :new.inventory_status,
           :new.truck_rail_number,
           :new.truck_rail_type,
           :new.packing_type_id,
           :new.handled_as,
           :new.allocated_no_of_units - :old.allocated_no_of_units,
           :new.current_no_of_units - :old.current_no_of_units,
           :new.stock_condition,
           :new.gravity_type_id,
           :new.gravity - :old.gravity,
           :new.density_mass_qty_unit_id,
           :new.density_volume_qty_unit_id,
           :new.gravity_type,
           :new.customs_id,
           :new.tax_id,
           :new.duty_id,
           :new.customer_seal_no,
           :new.brand,
           :new.no_of_containers - :old.no_of_containers,
           :new.no_of_bags - :old.no_of_bags,
           :new.no_of_pieces - :old.no_of_pieces,
           :new.rail_car_no,
           :new.sdcts_id,
           :new.partnership_type,
           :new.is_trans_ship,
           :new.is_mark_for_tolling,
           :new.tolling_qty - :old.tolling_qty,
           :new.tolling_stock_type,
           :new.element_id,
           :new.expected_sales_ccy,
           :new.profit_center_id,
           :new.strategy_id,
           :new.is_warrant,
           :new.warrant_no,
           :new.pcdi_id,
           :new.supp_contract_item_ref_no,
           :new.supplier_pcdi_id,
           :new.supp_internal_gmr_ref_no,
           :new.utility_header_id,
           :new.payable_returnable_type,
           :new.carry_over_qty - :old.carry_over_qty,
           :new.internal_action_ref_no,
           'Update',
           'N');
      else
        --Qty Unit is Updated
        insert into grdl_goods_record_detail_log
          (internal_grd_ref_no,
           internal_gmr_ref_no,
           product_id,
           is_afloat,
           status,
           qty_delta,
           qty_unit_id,
           gross_weight_delta,
           tare_weight_delta,
           internal_contract_item_ref_no,
           int_alloc_group_id,
           packing_size_id,
           container_no,
           seal_no,
           mark_no,
           warehouse_ref_no,
           no_of_units_delta,
           quality_id,
           warehouse_profile_id,
           shed_id,
           origin_id,
           crop_year_id,
           parent_id,
           is_released_shipped,
           release_shipped_no_units_delta,
           is_write_off,
           write_off_no_of_units_delta,
           is_moved_out,
           moved_out_no_of_units_delta,
           total_no_of_units_delta,
           total_qty_delta,
           moved_out_qty_delta,
           release_shipped_qty_delta,
           write_off_qty_delta,
           title_transfer_out_qty_delta,
           title_transfr_out_no_unt_delta,
           warehouse_receipt_no,
           warehouse_receipt_date,
           container_size,
           remarks,
           is_added_to_pool,
           loading_date,
           loading_country_id,
           loading_port_id,
           is_entire_item_loaded,
           is_weight_final,
           bl_number,
           bl_date,
           parent_internal_grd_ref_no,
           discharged_qty_delta,
           is_voyage_stock,
           allocated_qty_delta,
           internal_stock_ref_no,
           landed_no_of_units_delta,
           landed_net_qty_delta,
           landed_gross_qty_delta,
           shipped_no_of_units_delta,
           shipped_net_qty_delta,
           shipped_gross_qty_delta,
           current_qty_delta,
           stock_status,
           product_specs,
           source_type,
           source_int_stock_ref_no,
           source_int_purchase_ref_no,
           source_int_pool_ref_no,
           is_fulfilled,
           inventory_status,
           truck_rail_number,
           truck_rail_type,
           packing_type_id,
           handled_as,
           allocated_no_of_units_delta,
           current_no_of_units_delta,
           stock_condition,
           gravity_type_id,
           gravity_delta,
           density_mass_qty_unit_id,
           density_volume_qty_unit_id,
           gravity_type,
           customs_id,
           tax_id,
           duty_id,
           customer_seal_no,
           brand,
           no_of_containers_delta,
           no_of_bags_delta,
           no_of_pieces_delta,
           rail_car_no,
           sdcts_id,
           partnership_type,
           is_trans_ship,
           is_mark_for_tolling,
           tolling_qty,
           tolling_stock_type,
           element_id,
           expected_sales_ccy,
           profit_center_id,
           strategy_id,
           is_warrant,
           warrant_no,
           pcdi_id,
           supp_contract_item_ref_no,
           supplier_pcdi_id,
           supp_internal_gmr_ref_no,
           utility_header_id,
           payable_returnable_type,
           carry_over_qty,
           internal_action_ref_no,
           entry_type,
           is_deleted)
        values
          (:new.internal_grd_ref_no,
           :new.internal_gmr_ref_no,
           :new.product_id,
           :new.is_afloat,
           :new.status,
           :new.qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.qty),
           :new.qty_unit_id,
           :new.gross_weight -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.gross_weight),
           :new.tare_weight -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.tare_weight),
           :new.internal_contract_item_ref_no,
           :new.int_alloc_group_id,
           :new.packing_size_id,
           :new.container_no,
           :new.seal_no,
           :new.mark_no,
           :new.warehouse_ref_no,
           :new.no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.no_of_units),
           :new.quality_id,
           :new.warehouse_profile_id,
           :new.shed_id,
           :new.origin_id,
           :new.crop_year_id,
           :new.parent_id,
           :new.is_released_shipped,
           :new.release_shipped_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.release_shipped_no_of_units),
           :new.is_write_off,
           :new.write_off_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.write_off_no_of_units),
           :new.is_moved_out,
           :new.moved_out_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.moved_out_no_of_units),
           :new.total_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.total_no_of_units),
           :new.total_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.total_qty),
           :new.moved_out_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.moved_out_qty),
           :new.release_shipped_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.release_shipped_qty),
           :new.write_off_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.write_off_qty),
           :new.title_transfer_out_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.title_transfer_out_qty),
           :new.title_transfer_out_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.title_transfer_out_no_of_units),
           :new.warehouse_receipt_no,
           :new.warehouse_receipt_date,
           :new.container_size,
           :new.remarks,
           :new.is_added_to_pool,
           :new.loading_date,
           :new.loading_country_id,
           :new.loading_port_id,
           :new.is_entire_item_loaded,
           :new.is_weight_final,
           :new.bl_number,
           :new.bl_date,
           :new.parent_internal_grd_ref_no,
           :new.discharged_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.discharged_qty),
           :new.is_voyage_stock,
           :new.allocated_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.allocated_qty),
           :new.internal_stock_ref_no,
           :new.landed_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.landed_no_of_units),
           :new.landed_net_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.landed_net_qty),
           :new.landed_gross_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.landed_gross_qty),
           :new.shipped_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.shipped_no_of_units),
           :new.shipped_net_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.shipped_net_qty),
           :new.shipped_gross_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.shipped_gross_qty),
           :new.current_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.current_qty),
           :new.stock_status,
           :new.product_specs,
           :new.source_type,
           :new.source_int_stock_ref_no,
           :new.source_int_purchase_ref_no,
           :new.source_int_pool_ref_no,
           :new.is_fulfilled,
           :new.inventory_status,
           :new.truck_rail_number,
           :new.truck_rail_type,
           :new.packing_type_id,
           :new.handled_as,
           :new.allocated_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.allocated_no_of_units),
           :new.current_no_of_units -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.current_no_of_units),
           :new.stock_condition,
           :new.gravity_type_id,
           :new.gravity -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.gravity),
           :new.density_mass_qty_unit_id,
           :new.density_volume_qty_unit_id,
           :new.gravity_type,
           :new.customs_id,
           :new.tax_id,
           :new.duty_id,
           :new.customer_seal_no,
           :new.brand,
           :new.no_of_containers -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.no_of_containers),
           :new.no_of_bags -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.no_of_bags),
           :new.no_of_pieces -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.no_of_pieces),
           :new.rail_car_no,
           :new.sdcts_id,
           :new.partnership_type,
           :new.is_trans_ship,
           :new.is_mark_for_tolling,
           :new.tolling_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.tolling_qty),
           :new.tolling_stock_type,
           :new.element_id,
           :new.expected_sales_ccy,
           :new.profit_center_id,
           :new.strategy_id,
           :new.is_warrant,
           :new.warrant_no,
           :new.pcdi_id,
           :new.supp_contract_item_ref_no,
           :new.supplier_pcdi_id,
           :new.supp_internal_gmr_ref_no,
           :new.utility_header_id,
           :new.payable_returnable_type,
           :new.carry_over_qty -
           pkg_general.f_get_converted_quantity(:new.product_id,
                                                :old.qty_unit_id,
                                                :new.qty_unit_id,
                                                :old.carry_over_qty),
           :new.internal_action_ref_no,
           'Update',
           'N');
      end if;
    else
      -- IsDelete is yes
      insert into grdl_goods_record_detail_log
        (internal_grd_ref_no,
         internal_gmr_ref_no,
         product_id,
         is_afloat,
         status,
         qty_delta,
         qty_unit_id,
         gross_weight_delta,
         tare_weight_delta,
         internal_contract_item_ref_no,
         int_alloc_group_id,
         packing_size_id,
         container_no,
         seal_no,
         mark_no,
         warehouse_ref_no,
         no_of_units_delta,
         quality_id,
         warehouse_profile_id,
         shed_id,
         origin_id,
         crop_year_id,
         parent_id,
         is_released_shipped,
         release_shipped_no_units_delta,
         is_write_off,
         write_off_no_of_units_delta,
         is_moved_out,
         moved_out_no_of_units_delta,
         total_no_of_units_delta,
         total_qty_delta,
         moved_out_qty_delta,
         release_shipped_qty_delta,
         write_off_qty_delta,
         title_transfer_out_qty_delta,
         title_transfr_out_no_unt_delta,
         warehouse_receipt_no,
         warehouse_receipt_date,
         container_size,
         remarks,
         is_added_to_pool,
         loading_date,
         loading_country_id,
         loading_port_id,
         is_entire_item_loaded,
         is_weight_final,
         bl_number,
         bl_date,
         parent_internal_grd_ref_no,
         discharged_qty_delta,
         is_voyage_stock,
         allocated_qty_delta,
         internal_stock_ref_no,
         landed_no_of_units_delta,
         landed_net_qty_delta,
         landed_gross_qty_delta,
         shipped_no_of_units_delta,
         shipped_net_qty_delta,
         shipped_gross_qty_delta,
         current_qty_delta,
         stock_status,
         product_specs,
         source_type,
         source_int_stock_ref_no,
         source_int_purchase_ref_no,
         source_int_pool_ref_no,
         is_fulfilled,
         inventory_status,
         truck_rail_number,
         truck_rail_type,
         packing_type_id,
         handled_as,
         allocated_no_of_units_delta,
         current_no_of_units_delta,
         stock_condition,
         gravity_type_id,
         gravity_delta,
         density_mass_qty_unit_id,
         density_volume_qty_unit_id,
         gravity_type,
         customs_id,
         tax_id,
         duty_id,
         customer_seal_no,
         brand,
         no_of_containers_delta,
         no_of_bags_delta,
         no_of_pieces_delta,
         rail_car_no,
         sdcts_id,
         partnership_type,
         is_trans_ship,
         is_mark_for_tolling,
         tolling_qty,
         tolling_stock_type,
         element_id,
         expected_sales_ccy,
         profit_center_id,
         strategy_id,
         is_warrant,
         warrant_no,
         pcdi_id,
         supp_contract_item_ref_no,
         supplier_pcdi_id,
         supp_internal_gmr_ref_no,
         utility_header_id,
         payable_returnable_type,
         carry_over_qty,
         internal_action_ref_no,
         entry_type,
         is_deleted)
      values
        (:new.internal_grd_ref_no,
         :new.internal_gmr_ref_no,
         :new.product_id,
         :new.is_afloat,
         :new.status,
         :new.qty - :old.qty,
         :new.qty_unit_id,
         :new.gross_weight - :old.gross_weight,
         :new.tare_weight - :old.tare_weight,
         :new.internal_contract_item_ref_no,
         :new.int_alloc_group_id,
         :new.packing_size_id,
         :new.container_no,
         :new.seal_no,
         :new.mark_no,
         :new.warehouse_ref_no,
         :new.no_of_units - :old.no_of_units,
         :new.quality_id,
         :new.warehouse_profile_id,
         :new.shed_id,
         :new.origin_id,
         :new.crop_year_id,
         :new.parent_id,
         :new.is_released_shipped,
         :new.release_shipped_no_of_units -
         :old.release_shipped_no_of_units,
         :new.is_write_off,
         :new.write_off_no_of_units - :old.write_off_no_of_units,
         :new.is_moved_out,
         :new.moved_out_no_of_units - :old.moved_out_no_of_units,
         :new.total_no_of_units - :old.total_no_of_units,
         :new.total_qty - :old.total_qty,
         :new.moved_out_qty - :old.moved_out_qty,
         :new.release_shipped_qty - :old.release_shipped_qty,
         :new.write_off_qty - :old.write_off_qty,
         :new.title_transfer_out_qty - :old.title_transfer_out_qty,
         :new.title_transfer_out_no_of_units -
         :old.title_transfer_out_no_of_units,
         :new.warehouse_receipt_no,
         :new.warehouse_receipt_date,
         :new.container_size,
         :new.remarks,
         :new.is_added_to_pool,
         :new.loading_date,
         :new.loading_country_id,
         :new.loading_port_id,
         :new.is_entire_item_loaded,
         :new.is_weight_final,
         :new.bl_number,
         :new.bl_date,
         :new.parent_internal_grd_ref_no,
         :new.discharged_qty - :old.discharged_qty,
         :new.is_voyage_stock,
         :new.allocated_qty - :old.allocated_qty,
         :new.internal_stock_ref_no,
         :new.landed_no_of_units - :old.landed_no_of_units,
         :new.landed_net_qty - :old.landed_net_qty,
         :new.landed_gross_qty - :old.landed_gross_qty,
         :new.shipped_no_of_units - :old.shipped_no_of_units,
         :new.shipped_net_qty - :old.shipped_net_qty,
         :new.shipped_gross_qty - :old.shipped_gross_qty,
         :new.current_qty - :old.current_qty,
         :new.stock_status,
         :new.product_specs,
         :new.source_type,
         :new.source_int_stock_ref_no,
         :new.source_int_purchase_ref_no,
         :new.source_int_pool_ref_no,
         :new.is_fulfilled,
         :new.inventory_status,
         :new.truck_rail_number,
         :new.truck_rail_type,
         :new.packing_type_id,
         :new.handled_as,
         :new.allocated_no_of_units - :old.allocated_no_of_units,
         :new.current_no_of_units - :old.current_no_of_units,
         :new.stock_condition,
         :new.gravity_type_id,
         :new.gravity - :old.gravity,
         :new.density_mass_qty_unit_id,
         :new.density_volume_qty_unit_id,
         :new.gravity_type,
         :new.customs_id,
         :new.tax_id,
         :new.duty_id,
         :new.customer_seal_no,
         :new.brand,
         :new.no_of_containers - :old.no_of_containers,
         :new.no_of_bags - :old.no_of_bags,
         :new.no_of_pieces - :old.no_of_pieces,
         :new.rail_car_no,
         :new.sdcts_id,
         :new.partnership_type,
         :new.is_trans_ship,
         :new.is_mark_for_tolling,
         :new.tolling_qty - :old.tolling_qty,
         :new.tolling_stock_type,
         :new.element_id,
         :new.expected_sales_ccy,
         :new.profit_center_id,
         :new.strategy_id,
         :new.is_warrant,
         :new.warrant_no,
         :new.pcdi_id,
         :new.supp_contract_item_ref_no,
         :new.supplier_pcdi_id,
         :new.supp_internal_gmr_ref_no,
         :new.utility_header_id,
         :new.payable_returnable_type,
         :new.carry_over_qty - :old.carry_over_qty,
         :new.internal_action_ref_no,
         'Update',
         'Y');
    end if;
  else
    --
    -- New Entry ( Entry Type=Insert)
    --
    insert into grdl_goods_record_detail_log
      (internal_grd_ref_no,
       internal_gmr_ref_no,
       product_id,
       is_afloat,
       status,
       qty_delta,
       qty_unit_id,
       gross_weight_delta,
       tare_weight_delta,
       internal_contract_item_ref_no,
       int_alloc_group_id,
       packing_size_id,
       container_no,
       seal_no,
       mark_no,
       warehouse_ref_no,
       no_of_units_delta,
       quality_id,
       warehouse_profile_id,
       shed_id,
       origin_id,
       crop_year_id,
       parent_id,
       is_released_shipped,
       release_shipped_no_units_delta,
       is_write_off,
       write_off_no_of_units_delta,
       is_moved_out,
       moved_out_no_of_units_delta,
       total_no_of_units_delta,
       total_qty_delta,
       moved_out_qty_delta,
       release_shipped_qty_delta,
       write_off_qty_delta,
       title_transfer_out_qty_delta,
       title_transfr_out_no_unt_delta,
       warehouse_receipt_no,
       warehouse_receipt_date,
       container_size,
       remarks,
       is_added_to_pool,
       loading_date,
       loading_country_id,
       loading_port_id,
       is_entire_item_loaded,
       is_weight_final,
       bl_number,
       bl_date,
       parent_internal_grd_ref_no,
       discharged_qty_delta,
       is_voyage_stock,
       allocated_qty_delta,
       internal_stock_ref_no,
       landed_no_of_units_delta,
       landed_net_qty_delta,
       landed_gross_qty_delta,
       shipped_no_of_units_delta,
       shipped_net_qty_delta,
       shipped_gross_qty_delta,
       current_qty_delta,
       stock_status,
       product_specs,
       source_type,
       source_int_stock_ref_no,
       source_int_purchase_ref_no,
       source_int_pool_ref_no,
       is_fulfilled,
       inventory_status,
       truck_rail_number,
       truck_rail_type,
       packing_type_id,
       handled_as,
       allocated_no_of_units_delta,
       current_no_of_units_delta,
       stock_condition,
       gravity_type_id,
       gravity_delta,
       density_mass_qty_unit_id,
       density_volume_qty_unit_id,
       gravity_type,
       customs_id,
       tax_id,
       duty_id,
       customer_seal_no,
       brand,
       no_of_containers_delta,
       no_of_bags_delta,
       no_of_pieces_delta,
       rail_car_no,
       sdcts_id,
       partnership_type,
       is_trans_ship,
       is_mark_for_tolling,
       tolling_qty,
       tolling_stock_type,
       element_id,
       expected_sales_ccy,
       profit_center_id,
       strategy_id,
       is_warrant,
       warrant_no,
       pcdi_id,
       supp_contract_item_ref_no,
       supplier_pcdi_id,
       supp_internal_gmr_ref_no,
       utility_header_id,
       payable_returnable_type,
       carry_over_qty,
       internal_action_ref_no,
       entry_type,
       is_deleted)
    values
      (:new.internal_grd_ref_no,
       :new.internal_gmr_ref_no,
       :new.product_id,
       :new.is_afloat,
       :new.status,
       :new.qty,
       :new.qty_unit_id,
       :new.gross_weight,
       :new.tare_weight,
       :new.internal_contract_item_ref_no,
       :new.int_alloc_group_id,
       :new.packing_size_id,
       :new.container_no,
       :new.seal_no,
       :new.mark_no,
       :new.warehouse_ref_no,
       :new.no_of_units,
       :new.quality_id,
       :new.warehouse_profile_id,
       :new.shed_id,
       :new.origin_id,
       :new.crop_year_id,
       :new.parent_id,
       :new.is_released_shipped,
       :new.release_shipped_no_of_units,
       :new.is_write_off,
       :new.write_off_no_of_units,
       :new.is_moved_out,
       :new.moved_out_no_of_units,
       :new.total_no_of_units,
       :new.total_qty,
       :new.moved_out_qty,
       :new.release_shipped_qty,
       :new.write_off_qty,
       :new.title_transfer_out_qty,
       :new.title_transfer_out_no_of_units,
       :new.warehouse_receipt_no,
       :new.warehouse_receipt_date,
       :new.container_size,
       :new.remarks,
       :new.is_added_to_pool,
       :new.loading_date,
       :new.loading_country_id,
       :new.loading_port_id,
       :new.is_entire_item_loaded,
       :new.is_weight_final,
       :new.bl_number,
       :new.bl_date,
       :new.parent_internal_grd_ref_no,
       :new.discharged_qty,
       :new.is_voyage_stock,
       :new.allocated_qty,
       :new.internal_stock_ref_no,
       :new.landed_no_of_units,
       :new.landed_net_qty,
       :new.landed_gross_qty,
       :new.shipped_no_of_units,
       :new.shipped_net_qty,
       :new.shipped_gross_qty,
       :new.current_qty,
       :new.stock_status,
       :new.product_specs,
       :new.source_type,
       :new.source_int_stock_ref_no,
       :new.source_int_purchase_ref_no,
       :new.source_int_pool_ref_no,
       :new.is_fulfilled,
       :new.inventory_status,
       :new.truck_rail_number,
       :new.truck_rail_type,
       :new.packing_type_id,
       :new.handled_as,
       :new.allocated_no_of_units,
       :new.current_no_of_units,
       :new.stock_condition,
       :new.gravity_type_id,
       :new.gravity,
       :new.density_mass_qty_unit_id,
       :new.density_volume_qty_unit_id,
       :new.gravity_type,
       :new.customs_id,
       :new.tax_id,
       :new.duty_id,
       :new.customer_seal_no,
       :new.brand,
       :new.no_of_containers,
       :new.no_of_bags,
       :new.no_of_pieces,
       :new.rail_car_no,
       :new.sdcts_id,
       :new.partnership_type,
       :new.is_trans_ship,
       :new.is_mark_for_tolling,
       :new.tolling_qty,
       :new.tolling_stock_type,
       :new.element_id,
       :new.expected_sales_ccy,
       :new.profit_center_id,
       :new.strategy_id,
       :new.is_warrant,
       :new.warrant_no,
       :new.pcdi_id,
       :new.supp_contract_item_ref_no,
       :new.supplier_pcdi_id,
       :new.supp_internal_gmr_ref_no,
       :new.utility_header_id,
       :new.payable_returnable_type,
       :new.carry_over_qty,
       :new.internal_action_ref_no,
       'Insert',
       'N');
  end if;

  insert into aci_assay_content_update_input
    (internal_grd_no, cont_type, ash_id, is_deleted)
  values
    (:new.internal_grd_ref_no, 'GRD', null, 'N');
end;
declare

fetchqry1 clob := 'INSERT INTO VAT_D (
INTERNAL_INVOICE_REF_NO,
CONTRACT_REF_NO,
CP_CONTRACT_REF_NO,
INCO_TERM_LOCATION,
CONTRACT_DATE,
CP_NAME,
SELLER,
CONTRACT_QUANTITY,
CONTRACT_TOLERANCE,
PRODUCT,
QUALITY,
NOTIFY_PARTY,
INVOICE_CREATION_DATE,
INVOICE_DUE_DATE,
INVOICE_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
INTERNAL_DOC_REF_NO,
VAT_PARENT_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PCI.TERMS as INCO_TERM_LOCATION,
TO_CHAR(PCM.ISSUE_DATE, ''dd-Mon-yyyy'') as CONTRACT_DATE,
PHD.COMPANYNAME as CP_NAME,
'' as SELLER,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
'' as CONTRACT_TOLERANCE,
PDM.PRODUCT_DESC as PRODUCT,
QAT.QUALITY_NAME as QUALITY,
'' as NOTIFY_PARTY,
TO_CHAR(INVS.INVOICE_CREATED_DATE, ''dd-Mon-yyyy'') as INVOICE_CREATION_DATE,
TO_CHAR(INVS.PAYMENT_DUE_DATE, ''dd-Mon-yyyy'') as INVOICE_DUE_DATE,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
PCM.PURCHASE_SALES as SALES_PURCHASE,
?,
INVS.VAT_PARENT_REF_NO as VAT_PARENT_REF_NO
from
IS_INVOICE_SUMMARY invs,
IVD_INVOICE_VAT_DETAILS ivd,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd
where
INVS.INTERNAL_INVOICE_REF_NO = IVD.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCPD.INPUT_OUTPUT = ''Input''
and PCI.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCI.QUALITY_ID = QAT.QUALITY_ID
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INTERNAL_INVOICE_REF_NO = ?
group by 
INVS.INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO,
PCI.TERMS,
PCM.ISSUE_DATE,
PHD.COMPANYNAME,
PCPD.QTY_MAX_VAL,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
INVS.INVOICE_CREATED_DATE,
INVS.PAYMENT_DUE_DATE,
INVS.INVOICE_REF_NO,
PCM.CONTRACT_TYPE,
INVS.INVOICE_STATUS,
PCM.PURCHASE_SALES,
INVS.VAT_PARENT_REF_NO';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-VAT-1-CONC');
 commit;
  
end;
declare

fetchqry1 clob := 'INSERT INTO VAT_D (
INTERNAL_INVOICE_REF_NO,
CONTRACT_REF_NO,
CP_CONTRACT_REF_NO,
INCO_TERM_LOCATION,
CONTRACT_DATE,
CP_NAME,
SELLER,
CONTRACT_QUANTITY,
CONTRACT_TOLERANCE,
PRODUCT,
QUALITY,
NOTIFY_PARTY,
INVOICE_CREATION_DATE,
INVOICE_DUE_DATE,
INVOICE_REF_NO,
CONTRACT_TYPE,
INVOICE_STATUS,
SALES_PURCHASE,
INTERNAL_DOC_REF_NO,
VAT_PARENT_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO as CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO as CP_CONTRACT_REF_NO,
PCI.TERMS as INCO_TERM_LOCATION,
TO_CHAR(PCM.ISSUE_DATE, ''dd-Mon-yyyy'') as CONTRACT_DATE,
PHD.COMPANYNAME as CP_NAME,
'' as SELLER,
PCPD.QTY_MAX_VAL as CONTRACT_QUANTITY,
'' as CONTRACT_TOLERANCE,
PDM.PRODUCT_DESC as PRODUCT,
QAT.QUALITY_NAME as QUALITY,
'' as NOTIFY_PARTY,
TO_CHAR(INVS.INVOICE_CREATED_DATE, ''dd-Mon-yyyy'') as INVOICE_CREATION_DATE,
TO_CHAR(INVS.PAYMENT_DUE_DATE, ''dd-Mon-yyyy'') as INVOICE_DUE_DATE,
INVS.INVOICE_REF_NO as INVOICE_REF_NO,
PCM.CONTRACT_TYPE as CONTRACT_TYPE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
PCM.PURCHASE_SALES as SALES_PURCHASE,
'',
INVS.VAT_PARENT_REF_NO as VAT_PARENT_REF_NO
from
IS_INVOICE_SUMMARY invs,
IVD_INVOICE_VAT_DETAILS ivd,
PCM_PHYSICAL_CONTRACT_MAIN pcm,
v_pci pci,
PHD_PROFILEHEADERDETAILS phd,
PDM_PRODUCTMASTER pdm,
QAT_QUALITY_ATTRIBUTES qat,
PCPD_PC_PRODUCT_DEFINITION pcpd
where
INVS.INTERNAL_INVOICE_REF_NO = IVD.INTERNAL_INVOICE_REF_NO
and INVS.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID
and PCI.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
and PCI.QUALITY_ID = QAT.QUALITY_ID
AND PCM.CP_ID = PHD.PROFILEID(+)
and INVS.INTERNAL_INVOICE_REF_NO = ''
group by 
INVS.INTERNAL_INVOICE_REF_NO,
PCM.CONTRACT_REF_NO,
PCM.CP_CONTRACT_REF_NO,
PCI.TERMS,
PCM.ISSUE_DATE,
PHD.COMPANYNAME,
PCPD.QTY_MAX_VAL,
PDM.PRODUCT_DESC,
QAT.QUALITY_NAME,
INVS.INVOICE_CREATED_DATE,
INVS.PAYMENT_DUE_DATE,
INVS.INVOICE_REF_NO,
PCM.CONTRACT_TYPE,
INVS.INVOICE_STATUS,
PCM.PURCHASE_SALES,
INVS.VAT_PARENT_REF_NO';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-VAT-1');
 commit;
  
end;
delete from sls_static_list_setup sls where sls.list_type in ('reportList','ReportDataList');
delete from slv_static_list_value slv where slv.value_id in ('Detailed','Summarized','YTD');
delete from rpc_rf_parameter_config rpc where rpc.report_id = 255;
delete from rfc_report_filter_config rfc where rfc.report_id = 255;
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D255';
delete from rml_report_master_list rml where rml.report_id = 255;
commit;
SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Summarized', 'Summarized');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Detailed', 'Detailed');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('YTD', 'YTD');
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('reportList', 'Detailed', 'Y', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('reportList', 'Summarized', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('ReportDataList', 'YTD', 'Y', 1);
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('255', '31', 'MonthlyArrivalReport.rpt', 'Arrival Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');
COMMIT;
SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D255', 'Stock Recon Report', 22, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=255&ReportName=MonthlyArrivalReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
COMMIT;

SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
loop
    dbms_output.put_line(cc.corporate_id);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '255', 'RFC255PHY03', 1, 3, 
    'Smelter', 'GFF1001', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '255', 'RFC255PHY01', 1, 1, 
    'Year', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '255', 'RFC255PHY04', 1, 5, 
    'Report Type', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '255', 'RFC255PHY05', 1, 6, 
    'Product', 'GFF1011', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '255', 'RFC255PHY06', 1, 7, 
    'Quality', 'GFF1011', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '255', 'RFC255PHY02', 1, 2, 
    'Month', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '255', 'RFC255PHY08', 1, 4, 
    'Report Data', 'GFF1012', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY08', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY08', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY08', 'RFP1060', 'ReportDataList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY08', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY08', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY08', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY08', 'RFP1061', 'ReportData');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY02', 'RFP1060', 'MonthList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY02', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY02', 'RFP1061', 'Month');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY02', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY02', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY02', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY02', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY01', 'RFP1060', 'yearList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY01', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY01', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY01', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY01', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY01', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY01', 'RFP1061', 'Year');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY04', 'RFP1060', 'reportList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY04', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY04', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY04', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY04', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY04', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY04', 'RFP1061', 'ReportType');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY05', 'RFP1045', 'allProducts');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY05', 'RFP1046', 'Product');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY05', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY05', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY05', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY05', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY05', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY06', 'RFP1045', 'quality');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY06', 'RFP1046', 'Quality');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY06', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY06', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY06', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY06', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY06', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY03', 'RFP1001', 'businesspartner');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY03', 'RFP1002', 'Arrival');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY03', 'RFP1003', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY03', 'RFP1004', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY03', 'RFP1005', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY03', 'RFP1006', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '255', 'RFC255PHY03', 'RFP1008', 'WAREHOUSING');
COMMIT;
  end loop;
commit;
end;

alter table FMUH_FREE_METAL_UTILITY_HEADER add (PROFIT_CENTER_ID varchar2(15), STRATEGY_ID varchar2(15));

alter table FMED_FREE_METAL_ELEMT_DETAILS add (PROVISIONAL_PRICE NUMBER(25,10));
SET DEFINE OFF;
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-IEFPD_C', 'CREATE_DFI', 'Concentrate Direct Final Invoice', 'CREATE_DFI', 13, 
    'INSERT INTO IEFPD_D(
  INTERNAL_INVOICE_REF_NO,
  INTERNAL_GMR_REF_NO,
  GMR_REF_NO,
  ELEMENT_ID,
  ELEMENT_NAME,
  QTY_UNIT_NAME,
  TOTAL_QTY_PRICED,
  WT_AVG_FX_RATE,
  WT_AVG_PRICE_IN_PRICING_CUR,
  PRICING_CUR_NAME,
  WT_AVG_PRICE_IN_PAY_IN_CUR,
  PAY_IN_CUR_NAME,
  INTERNAL_DOC_REF_NO
  )
  select distinct
    INVS.INTERNAL_INVOICE_REF_NO AS INTERNAL_INVOICE_REF_NO,
    GMR.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    GMR.GMR_REF_NO AS GMR_REF_NO,
    IEFPD.ELEMENT_ID AS ELEMENT_ID,
    IEFPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEFPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    IEFPD.TOTAL_QTY_PRICED AS TOTAL_QTY_PRICED,
    IEFPD.WT_AVG_FX_RATE AS WT_AVG_FX_RATE,
    IEFPD.WT_AVG_PRICE_IN_PRICING_CUR AS WT_AVG_PRICE_IN_PRICING_CUR,
    IEFPD.PRICING_CUR_NAME AS PRICING_CUR_NAME, 
    IEFPD.WT_AVG_PRICE_IN_PAY_IN_CUR AS WT_AVG_PRICE_IN_PAY_IN_CUR,
    IEFPD.PAY_IN_CUR_NAME AS PAY_IN_CUR_NAME,
     ?
    from
    IS_INVOICE_SUMMARY invs,
    IEFPD_IEF_PRICING_DETAIL IEFPD,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEFPD.INTERNAL_INVOICE_REF_NO
    AND IEFPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    AND IEFPD.INTERNAL_INVOICE_REF_NO = ?', 'Y');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-IEPD_C', 'CREATE_DFI', 'Concentrate Direct Final Invoice', 'CREATE_DFI', 12, 
    ' INSERT INTO IEPD_D(
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
DELIVERY_ITEM_REF_NO,
INTERNAL_GMR_REF_NO,
ELEMENT_ID,
ELEMENT_NAME,
FX_RATE,
GMR_REF_NO,
INVOICE_CUR_NAME,
INVOICE_PRICE_UNIT_NAME,
ADJUSTMENT,
PRICE,
PRICE_FIXATION_DATE,
PRICE_FIXATION_REF_NO,
PRICE_IN_PAY_IN_CUR,
PRICING_CUR_NAME,
PRICING_PRICE_UNIT_NAME,
PRICING_TYPE,
PRODUCT_NAME,
QTY_PRICED,
QTY_UNIT_NAME,
QP_START_DATE,
QP_END_DATE,
QP_PERIOD_TYPE,
INTERNAL_DOC_REF_NO)
select distinct
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    IEPD.AMOUNT_IN_PAY_IN_CUR AS INVOICE_AMOUNT,
    IEPD.DELIVERY_ITEM_REF_NO AS DELIVERY_ITEM_REF_NO,
    IEPD.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    IEPD.ELEMENT_ID AS ELEMENT_ID,
    IEPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEPD.FX_RATE AS FX_RATE,
    GMR.GMR_REF_NO AS GMR_REF_NO, 
    IEPD.PAY_IN_CUR_NAME AS INVOICE_CUR_NAME,
    IEPD.PAY_IN_PRICE_UNIT_NAME AS INVOICE_PRICE_UNIT_NAME,
    IEPD.ADJUSTMENT AS ADJUSTMENT,
    IEPD.PRICE AS PRICE,
    IEPD.PRICE_FIXATION_DATE AS PRICE_FIXATION_DATE,
    IEPD.PRICE_FIXATION_REF_NO AS PRICE_FIXATION_REF_NO,
    IEPD.PRICE_IN_PAY_IN_CUR AS PRICE_IN_PAY_IN_CUR,
    IEPD.PRICING_CUR_NAME AS PRICING_CUR_NAME,
    IEPD.PRICING_PRICE_UNIT_NAME AS PRICING_PRICE_UNIT_NAME,
    IEPD.PRICING_TYPE AS PRICING_TYPE,
    PDM.PRODUCT_DESC AS PRODUCT_NAME,
    IEPD.QTY_PRICED AS QTY_PRICED,
    IEPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    POFH.QP_START_DATE AS QP_START_DATE,
    POFH.QP_END_DATE AS QP_END_DATE,
    PFQPP.QP_PRICING_PERIOD_TYPE AS QP_PERIOD_TYPE,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IEPD_INV_ELE_PRICING_DETAIL IEPD,
    PDM_PRODUCTMASTER PDM,
    POFH_PRICE_OPT_FIXATION_HEADER POFH,
    PCBPH_PC_BASE_PRICE_HEADER PCBPH,
    PCBPD_PC_BASE_PRICE_DETAIL PCBPD,
    PPFH_PHY_PRICE_FORMULA_HEADER PPFH,
    PFQPP_PHY_FORMULA_QP_PRICING PFQPP,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEPD.INTERNAL_INVOICE_REF_NO
    AND IEPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
    AND IEPD.POFH_ID = POFH.POFH_ID(+)
    AND IEPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    and pcbph.internal_contract_ref_no = INVS.INTERNAL_CONTRACT_REF_NO 
    and pcbph.pcbph_id = pcbpd.pcbph_id
    and pcbpd.pcbpd_id = ppfh.pcbpd_id
    and ppfh.ppfh_id = pfqpp.ppfh_id
    and IEPD.INTERNAL_INVOICE_REF_NO = ?
    ', 'Y');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFI-C8', 'CREATE_DFI', 'Direct Final Invoice', 'CREATE_DFI', 9, 
    ' INSERT INTO IEPD_D(
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
DELIVERY_ITEM_REF_NO,
INTERNAL_GMR_REF_NO,
ELEMENT_ID,
ELEMENT_NAME,
FX_RATE,
GMR_REF_NO,
INVOICE_CUR_NAME,
INVOICE_PRICE_UNIT_NAME,
ADJUSTMENT,
PRICE,
PRICE_FIXATION_DATE,
PRICE_FIXATION_REF_NO,
PRICE_IN_PAY_IN_CUR,
PRICING_CUR_NAME,
PRICING_PRICE_UNIT_NAME,
PRICING_TYPE,
PRODUCT_NAME,
QTY_PRICED,
QTY_UNIT_NAME,
QP_START_DATE,
QP_END_DATE,
QP_PERIOD_TYPE,
INTERNAL_DOC_REF_NO)
select distinct
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    IEPD.AMOUNT_IN_PAY_IN_CUR AS INVOICE_AMOUNT,
    IEPD.DELIVERY_ITEM_REF_NO AS DELIVERY_ITEM_REF_NO,
    IEPD.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    IEPD.ELEMENT_ID AS ELEMENT_ID,
    IEPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEPD.FX_RATE AS FX_RATE,
    GMR.GMR_REF_NO AS GMR_REF_NO, 
    IEPD.PAY_IN_CUR_NAME AS INVOICE_CUR_NAME,
    IEPD.PAY_IN_PRICE_UNIT_NAME AS INVOICE_PRICE_UNIT_NAME,
    IEPD.ADJUSTMENT AS ADJUSTMENT,
    IEPD.PRICE AS PRICE,
    IEPD.PRICE_FIXATION_DATE AS PRICE_FIXATION_DATE,
    IEPD.PRICE_FIXATION_REF_NO AS PRICE_FIXATION_REF_NO,
    IEPD.PRICE_IN_PAY_IN_CUR AS PRICE_IN_PAY_IN_CUR,
    IEPD.PRICING_CUR_NAME AS PRICING_CUR_NAME,
    IEPD.PRICING_PRICE_UNIT_NAME AS PRICING_PRICE_UNIT_NAME,
    IEPD.PRICING_TYPE AS PRICING_TYPE,
    PDM.PRODUCT_DESC AS PRODUCT_NAME,
    IEPD.QTY_PRICED AS QTY_PRICED,
    IEPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    POFH.QP_START_DATE AS QP_START_DATE,
    POFH.QP_END_DATE AS QP_END_DATE,
    PFQPP.QP_PRICING_PERIOD_TYPE AS QP_PERIOD_TYPE,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IEPD_INV_ELE_PRICING_DETAIL IEPD,
    PDM_PRODUCTMASTER PDM,
    POFH_PRICE_OPT_FIXATION_HEADER POFH,
    PCBPH_PC_BASE_PRICE_HEADER PCBPH,
    PCBPD_PC_BASE_PRICE_DETAIL PCBPD,
    PPFH_PHY_PRICE_FORMULA_HEADER PPFH,
    PFQPP_PHY_FORMULA_QP_PRICING PFQPP,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEPD.INTERNAL_INVOICE_REF_NO
    AND IEPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
    AND IEPD.POFH_ID = POFH.POFH_ID(+)
    AND IEPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    and pcbph.internal_contract_ref_no = INVS.INTERNAL_CONTRACT_REF_NO 
    and pcbph.pcbph_id = pcbpd.pcbph_id
    and pcbpd.pcbpd_id = ppfh.pcbpd_id
    and ppfh.ppfh_id = pfqpp.ppfh_id
    and IEPD.INTERNAL_INVOICE_REF_NO = ?
    ', 'N');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-DFI-C9', 'CREATE_DFI', 'Direct Final Invoice', 'CREATE_DFI', 10, 
    'INSERT INTO IEFPD_D(
  INTERNAL_INVOICE_REF_NO,
  INTERNAL_GMR_REF_NO,
  GMR_REF_NO,
  ELEMENT_ID,
  ELEMENT_NAME,
  QTY_UNIT_NAME,
  TOTAL_QTY_PRICED,
  WT_AVG_FX_RATE,
  WT_AVG_PRICE_IN_PRICING_CUR,
  PRICING_CUR_NAME,
  WT_AVG_PRICE_IN_PAY_IN_CUR,
  PAY_IN_CUR_NAME,
  INTERNAL_DOC_REF_NO
  )
  select distinct
    INVS.INTERNAL_INVOICE_REF_NO AS INTERNAL_INVOICE_REF_NO,
    GMR.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    GMR.GMR_REF_NO AS GMR_REF_NO,
    IEFPD.ELEMENT_ID AS ELEMENT_ID,
    IEFPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEFPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    IEFPD.TOTAL_QTY_PRICED AS TOTAL_QTY_PRICED,
    IEFPD.WT_AVG_FX_RATE AS WT_AVG_FX_RATE,
    IEFPD.WT_AVG_PRICE_IN_PRICING_CUR AS WT_AVG_PRICE_IN_PRICING_CUR,
    IEFPD.PRICING_CUR_NAME AS PRICING_CUR_NAME, 
    IEFPD.WT_AVG_PRICE_IN_PAY_IN_CUR AS WT_AVG_PRICE_IN_PAY_IN_CUR,
    IEFPD.PAY_IN_CUR_NAME AS PAY_IN_CUR_NAME,
     ?
    from
    IS_INVOICE_SUMMARY invs,
    IEFPD_IEF_PRICING_DETAIL IEFPD,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEFPD.INTERNAL_INVOICE_REF_NO
    AND IEFPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    AND IEFPD.INTERNAL_INVOICE_REF_NO = ?', 'N');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-IEFPD_C', 'CREATE_FI', 'Concentrate Final Invoice', 'CREATE_FI', 13, 
    'INSERT INTO IEFPD_D(
  INTERNAL_INVOICE_REF_NO,
  INTERNAL_GMR_REF_NO,
  GMR_REF_NO,
  ELEMENT_ID,
  ELEMENT_NAME,
  QTY_UNIT_NAME,
  TOTAL_QTY_PRICED,
  WT_AVG_FX_RATE,
  WT_AVG_PRICE_IN_PRICING_CUR,
  PRICING_CUR_NAME,
  WT_AVG_PRICE_IN_PAY_IN_CUR,
  PAY_IN_CUR_NAME,
  INTERNAL_DOC_REF_NO
  )
  select distinct
    INVS.INTERNAL_INVOICE_REF_NO AS INTERNAL_INVOICE_REF_NO,
    GMR.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    GMR.GMR_REF_NO AS GMR_REF_NO,
    IEFPD.ELEMENT_ID AS ELEMENT_ID,
    IEFPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEFPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    IEFPD.TOTAL_QTY_PRICED AS TOTAL_QTY_PRICED,
    IEFPD.WT_AVG_FX_RATE AS WT_AVG_FX_RATE,
    IEFPD.WT_AVG_PRICE_IN_PRICING_CUR AS WT_AVG_PRICE_IN_PRICING_CUR,
    IEFPD.PRICING_CUR_NAME AS PRICING_CUR_NAME, 
    IEFPD.WT_AVG_PRICE_IN_PAY_IN_CUR AS WT_AVG_PRICE_IN_PAY_IN_CUR,
    IEFPD.PAY_IN_CUR_NAME AS PAY_IN_CUR_NAME,
     ?
    from
    IS_INVOICE_SUMMARY invs,
    IEFPD_IEF_PRICING_DETAIL IEFPD,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEFPD.INTERNAL_INVOICE_REF_NO
    AND IEFPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    AND IEFPD.INTERNAL_INVOICE_REF_NO = ?', 'Y');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-IEPD_C', 'CREATE_FI', 'Concentrate Final Invoice', 'CREATE_FI', 12, 
    ' INSERT INTO IEPD_D(
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
DELIVERY_ITEM_REF_NO,
INTERNAL_GMR_REF_NO,
ELEMENT_ID,
ELEMENT_NAME,
FX_RATE,
GMR_REF_NO,
INVOICE_CUR_NAME,
INVOICE_PRICE_UNIT_NAME,
ADJUSTMENT,
PRICE,
PRICE_FIXATION_DATE,
PRICE_FIXATION_REF_NO,
PRICE_IN_PAY_IN_CUR,
PRICING_CUR_NAME,
PRICING_PRICE_UNIT_NAME,
PRICING_TYPE,
PRODUCT_NAME,
QTY_PRICED,
QTY_UNIT_NAME,
QP_START_DATE,
QP_END_DATE,
QP_PERIOD_TYPE,
INTERNAL_DOC_REF_NO)
select distinct
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    IEPD.AMOUNT_IN_PAY_IN_CUR AS INVOICE_AMOUNT,
    IEPD.DELIVERY_ITEM_REF_NO AS DELIVERY_ITEM_REF_NO,
    IEPD.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    IEPD.ELEMENT_ID AS ELEMENT_ID,
    IEPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEPD.FX_RATE AS FX_RATE,
    GMR.GMR_REF_NO AS GMR_REF_NO, 
    IEPD.PAY_IN_CUR_NAME AS INVOICE_CUR_NAME,
    IEPD.PAY_IN_PRICE_UNIT_NAME AS INVOICE_PRICE_UNIT_NAME,
    IEPD.ADJUSTMENT AS ADJUSTMENT,
    IEPD.PRICE AS PRICE,
    IEPD.PRICE_FIXATION_DATE AS PRICE_FIXATION_DATE,
    IEPD.PRICE_FIXATION_REF_NO AS PRICE_FIXATION_REF_NO,
    IEPD.PRICE_IN_PAY_IN_CUR AS PRICE_IN_PAY_IN_CUR,
    IEPD.PRICING_CUR_NAME AS PRICING_CUR_NAME,
    IEPD.PRICING_PRICE_UNIT_NAME AS PRICING_PRICE_UNIT_NAME,
    IEPD.PRICING_TYPE AS PRICING_TYPE,
    PDM.PRODUCT_DESC AS PRODUCT_NAME,
    IEPD.QTY_PRICED AS QTY_PRICED,
    IEPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    POFH.QP_START_DATE AS QP_START_DATE,
    POFH.QP_END_DATE AS QP_END_DATE,
    PFQPP.QP_PRICING_PERIOD_TYPE AS QP_PERIOD_TYPE,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IEPD_INV_ELE_PRICING_DETAIL IEPD,
    PDM_PRODUCTMASTER PDM,
    POFH_PRICE_OPT_FIXATION_HEADER POFH,
    PCBPH_PC_BASE_PRICE_HEADER PCBPH,
    PCBPD_PC_BASE_PRICE_DETAIL PCBPD,
    PPFH_PHY_PRICE_FORMULA_HEADER PPFH,
    PFQPP_PHY_FORMULA_QP_PRICING PFQPP,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEPD.INTERNAL_INVOICE_REF_NO
    AND IEPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
    AND IEPD.POFH_ID = POFH.POFH_ID(+)
    AND IEPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    and pcbph.internal_contract_ref_no = INVS.INTERNAL_CONTRACT_REF_NO 
    and pcbph.pcbph_id = pcbpd.pcbph_id
    and pcbpd.pcbpd_id = ppfh.pcbpd_id
    and ppfh.ppfh_id = pfqpp.ppfh_id
    and IEPD.INTERNAL_INVOICE_REF_NO = ?
    ', 'Y');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-IEPD_BM', 'CREATE_FI', 'Final Invoice', 'CREATE_FI', 9, 
    ' INSERT INTO IEPD_D(
INTERNAL_INVOICE_REF_NO,
INVOICE_AMOUNT,
DELIVERY_ITEM_REF_NO,
INTERNAL_GMR_REF_NO,
ELEMENT_ID,
ELEMENT_NAME,
FX_RATE,
GMR_REF_NO,
INVOICE_CUR_NAME,
INVOICE_PRICE_UNIT_NAME,
ADJUSTMENT,
PRICE,
PRICE_FIXATION_DATE,
PRICE_FIXATION_REF_NO,
PRICE_IN_PAY_IN_CUR,
PRICING_CUR_NAME,
PRICING_PRICE_UNIT_NAME,
PRICING_TYPE,
PRODUCT_NAME,
QTY_PRICED,
QTY_UNIT_NAME,
QP_START_DATE,
QP_END_DATE,
QP_PERIOD_TYPE,
INTERNAL_DOC_REF_NO)
select distinct
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    IEPD.AMOUNT_IN_PAY_IN_CUR AS INVOICE_AMOUNT,
    IEPD.DELIVERY_ITEM_REF_NO AS DELIVERY_ITEM_REF_NO,
    IEPD.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    IEPD.ELEMENT_ID AS ELEMENT_ID,
    IEPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEPD.FX_RATE AS FX_RATE,
    GMR.GMR_REF_NO AS GMR_REF_NO, 
    IEPD.PAY_IN_CUR_NAME AS INVOICE_CUR_NAME,
    IEPD.PAY_IN_PRICE_UNIT_NAME AS INVOICE_PRICE_UNIT_NAME,
    IEPD.ADJUSTMENT AS ADJUSTMENT,
    IEPD.PRICE AS PRICE,
    IEPD.PRICE_FIXATION_DATE AS PRICE_FIXATION_DATE,
    IEPD.PRICE_FIXATION_REF_NO AS PRICE_FIXATION_REF_NO,
    IEPD.PRICE_IN_PAY_IN_CUR AS PRICE_IN_PAY_IN_CUR,
    IEPD.PRICING_CUR_NAME AS PRICING_CUR_NAME,
    IEPD.PRICING_PRICE_UNIT_NAME AS PRICING_PRICE_UNIT_NAME,
    IEPD.PRICING_TYPE AS PRICING_TYPE,
    PDM.PRODUCT_DESC AS PRODUCT_NAME,
    IEPD.QTY_PRICED AS QTY_PRICED,
    IEPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    POFH.QP_START_DATE AS QP_START_DATE,
    POFH.QP_END_DATE AS QP_END_DATE,
    PFQPP.QP_PRICING_PERIOD_TYPE AS QP_PERIOD_TYPE,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IEPD_INV_ELE_PRICING_DETAIL IEPD,
    PDM_PRODUCTMASTER PDM,
    POFH_PRICE_OPT_FIXATION_HEADER POFH,
    PCBPH_PC_BASE_PRICE_HEADER PCBPH,
    PCBPD_PC_BASE_PRICE_DETAIL PCBPD,
    PPFH_PHY_PRICE_FORMULA_HEADER PPFH,
    PFQPP_PHY_FORMULA_QP_PRICING PFQPP,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEPD.INTERNAL_INVOICE_REF_NO
    AND IEPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
    AND IEPD.POFH_ID = POFH.POFH_ID(+)
    AND IEPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    and pcbph.internal_contract_ref_no = INVS.INTERNAL_CONTRACT_REF_NO 
    and pcbph.pcbph_id = pcbpd.pcbph_id
    and pcbpd.pcbpd_id = ppfh.pcbpd_id
    and ppfh.ppfh_id = pfqpp.ppfh_id
    and IEPD.INTERNAL_INVOICE_REF_NO = ?
    ', 'N');
Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-IEFPD_BM', 'CREATE_FI', 'Final Invoice', 'CREATE_FI', 10, 
    'INSERT INTO IEFPD_D(
  INTERNAL_INVOICE_REF_NO,
  INTERNAL_GMR_REF_NO,
  GMR_REF_NO,
  ELEMENT_ID,
  ELEMENT_NAME,
  QTY_UNIT_NAME,
  TOTAL_QTY_PRICED,
  WT_AVG_FX_RATE,
  WT_AVG_PRICE_IN_PRICING_CUR,
  PRICING_CUR_NAME,
  WT_AVG_PRICE_IN_PAY_IN_CUR,
  PAY_IN_CUR_NAME,
  INTERNAL_DOC_REF_NO
  )
  select distinct
    INVS.INTERNAL_INVOICE_REF_NO AS INTERNAL_INVOICE_REF_NO,
    GMR.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
    GMR.GMR_REF_NO AS GMR_REF_NO,
    IEFPD.ELEMENT_ID AS ELEMENT_ID,
    IEFPD.ELEMENT_NAME AS ELEMENT_NAME,
    IEFPD.QTY_UNIT_NAME AS QTY_UNIT_NAME,
    IEFPD.TOTAL_QTY_PRICED AS TOTAL_QTY_PRICED,
    IEFPD.WT_AVG_FX_RATE AS WT_AVG_FX_RATE,
    IEFPD.WT_AVG_PRICE_IN_PRICING_CUR AS WT_AVG_PRICE_IN_PRICING_CUR,
    IEFPD.PRICING_CUR_NAME AS PRICING_CUR_NAME, 
    IEFPD.WT_AVG_PRICE_IN_PAY_IN_CUR AS WT_AVG_PRICE_IN_PAY_IN_CUR,
    IEFPD.PAY_IN_CUR_NAME AS PAY_IN_CUR_NAME,
     ?
    from
    IS_INVOICE_SUMMARY invs,
    IEFPD_IEF_PRICING_DETAIL IEFPD,
    GMR_GOODS_MOVEMENT_RECORD GMR
    where
    INVS.INTERNAL_INVOICE_REF_NO = IEFPD.INTERNAL_INVOICE_REF_NO
    AND IEFPD.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
    AND IEFPD.INTERNAL_INVOICE_REF_NO = ?', 'N');
COMMIT;
ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD
(
   FIRST_INT_ACTION_REF_NO VARCHAR2(15),
   CONSTRAINT FK_GRD_FIRST_ACTION_REF_NO FOREIGN KEY (FIRST_INT_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);

ALTER TABLE GRDUL_GOODS_RECORD_DETAIL_UL ADD
(
   FIRST_INT_ACTION_REF_NO VARCHAR2(15)
);

ALTER TABLE AGRD_ACTION_GRD ADD
(
   FIRST_INT_ACTION_REF_NO VARCHAR2(15),
   CONSTRAINT FK_AGRD_FIRST_ACTION_REF_NO FOREIGN KEY (FIRST_INT_ACTION_REF_NO) REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO)
);



UPDATE grd_goods_record_detail grd
   SET grd.first_int_action_ref_no = grd.internal_action_ref_no
 WHERE grd.tolling_stock_type IN
          ('MFT In Process Stock', 'Delta MFT IP Stock',
           'Free Material Stock', 'Free Metal IP Stock', 'Delta FM IP Stock');
           

UPDATE AGRD_ACTION_GRD agrd
   SET agrd.first_int_action_ref_no = (select grd.internal_action_ref_no
   from GRD_GOODS_RECORD_DETAIL grd
 WHERE AGRD.INTERNAL_GRD_REF_NO = GRD.INTERNAL_GRD_REF_NO
 and AGRD.TOLLING_STOCK_TYPE = GRD.TOLLING_STOCK_TYPE
 and agrd.tolling_stock_type IN
          ('MFT In Process Stock', 'Delta MFT IP Stock',
           'Free Material Stock', 'Free Metal IP Stock', 'Delta FM IP Stock'));
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
       ips_temp.input_stock_ref_no,
       ips_temp.utility_header_id,
       fmuh.utility_ref_no
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
               grd_cloned.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id
          from grd_goods_record_detail      grd,
               grd_goods_record_detail      grd_cloned,
               pdm_productmaster            pdm_consc,
               gmr_goods_movement_record    gmr,
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
           and axs.internal_action_ref_no = grd.first_int_action_ref_no
           and axm.action_id = axs.action_id
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
               grd_parent.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id
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
               agrd_cloned.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id
          from agrd_action_grd              agrd,
               grd_goods_record_detail      grd,
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
           and axs.internal_action_ref_no = agrd.first_int_action_ref_no
           and axs.status = 'Active'
           and axm.action_id = axs.action_id
           and agrd_cloned.internal_grd_ref_no =
               agrd_fm.parent_internal_grd_ref_no
           and agrd_fm.internal_grd_ref_no = agrd.parent_internal_grd_ref_no
           and agrd_cloned.is_deleted = 'N'
           and agrd_cloned.status = 'Active'
           and pdm_consc.product_id = agrd_cloned.product_id
           and grd.internal_grd_ref_no = agrd.internal_grd_ref_no
        
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
        '' input_stock_ref_no,
        '' utility_header_id
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
        ) ips_temp,
       fmuh_free_metal_utility_header fmuh
 where ips_temp.utility_header_id = fmuh.fmuh_id(+);
/
create or replace view v_metal_accounts_transactions as
select mat_temp.unique_id,
       mat_temp.corporate_id,
       mat_temp.contract_type,
       mat_temp.internal_contract_ref_no,
       mat_temp.contract_ref_no,
       mat_temp.contract_middle_no,
       mat_temp.internal_contract_item_ref_no,
       mat_temp.contract_item_ref_no,
       mat_temp.pcdi_id,
       mat_temp.delivery_item_no,
       mat_temp.del_distribution_item_no,
       mat_temp.delivery_item_ref_no,
       mat_temp.stock_id,
       mat_temp.stock_ref_no,
       mat_temp.internal_gmr_ref_no,
       mat_temp.gmr_ref_no,
       mat_temp.activity_action_id,
       axm.action_name activity_action_name,
       mat_temp.supplier_id,
       phd.companyname supplier_name,
       mat_temp.debt_supplier_id,
       phd_debt.companyname debt_supplier_name,
       mat_temp.product_id,
       mat_temp.product_name,
       mat_temp.debt_qty,
       nvl(mat_temp.ext_debt_qty, 0) ext_debt_qty,
       mat_temp.debt_qty_unit_id,
       qum.qty_unit debt_qty_unit,
       mat_temp.internal_action_ref_no,
       to_char(mat_temp.activity_date, 'dd-Mon-yyyy') activity_date,
       mat_temp.assay_content,
       nvl(mat_temp.ext_assay_content, 0) ext_assay_content,
       nvl(mat_temp.assay_finalized, 'N') assay_finalized,
       mat_temp.due_date
  from (select retn_temp.unique_id,
               retn_temp.corporate_id,
               retn_temp.contract_type,
               retn_temp.internal_contract_ref_no,
               retn_temp.contract_ref_no,
               retn_temp.contract_middle_no,
               retn_temp.internal_contract_item_ref_no,
               retn_temp.contract_item_ref_no,
               retn_temp.pcdi_id,
               retn_temp.delivery_item_no,
               retn_temp.del_distribution_item_no,
               retn_temp.delivery_item_ref_no,
               retn_temp.stock_id,
               retn_temp.stock_ref_no,
               retn_temp.internal_gmr_ref_no,
               retn_temp.gmr_ref_no,
               retn_temp.activity_action_id,
               retn_temp.supplier_id,
               retn_temp.to_supplier_id debt_supplier_id,
               retn_temp.product_id,
               retn_temp.product_name,
               (-1 * retn_temp.qty) debt_qty,
               (-1 * retn_temp.ext_qty) ext_debt_qty,
               retn_temp.qty_unit_id debt_qty_unit_id,
               retn_temp.internal_action_ref_no,
               retn_temp.activity_date,
               (-1 * retn_temp.assay_content) assay_content,
               (-1 * retn_temp.ext_assay_content) ext_assay_content,
               retn_temp.assay_finalized,
               retn_temp.due_date
          from (select spq.spq_id unique_id,
                       spq.corporate_id,
                       pci.contract_type,
                       pci.internal_contract_ref_no,
                       pci.contract_ref_no,
                       pci.middle_no contract_middle_no,
                       pci.internal_contract_item_ref_no,
                       pci.contract_item_ref_no,
                       pci.pcdi_id,
                       pci.delivery_item_no,
                       pci.del_distribution_item_no,
                       pci.delivery_item_ref_no,
                       spq.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       spq.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       spq.activity_action_id,
                       spq.supplier_id,
                       '' to_supplier_id,
                       bvc_product.base_product_id product_id,
                       bvc_product.base_product_name product_name,
                       spq.payable_qty qty,
                       spq.ext_payable_qty ext_qty,
                       spq.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       spq.assay_content,
                       spq.ext_assay_content ext_assay_content,
                       spq.is_final_assay assay_finalized,
                       spq.due_date
                  from spq_stock_payable_qty       spq,
                       grd_goods_record_detail     grd,
                       v_pci                       pci,
                       gmr_goods_movement_record   gmr,
                       axs_action_summary          axs,
                       v_list_base_vs_conc_product bvc_product
                 where spq.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and spq.smelter_id is null
                   and spq.is_active = 'Y'
                   and spq.is_stock_split = 'N'
                   and spq.qty_type = 'Returnable'
                   and bvc_product.element_id = spq.element_id
                   and bvc_product.product_id = grd.product_id
                   and bvc_product.quality_id = grd.quality_id
                   and grd.internal_grd_ref_no = spq.internal_grd_ref_no
                   and gmr.internal_gmr_ref_no = spq.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                union
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       pci.contract_type,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       pci.middle_no contract_middle_no,
                       grd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_no,
                       pci.del_distribution_item_no,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       grd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       (prrqs.qty_sign * prrqs.assay_content) assay_content,
                       (prrqs.qty_sign * 0) ext_assay_content,
                       '' assay_finalized,
                       prrqs.due_date
                  from prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       grd_goods_record_detail   grd,
                       gmr_goods_movement_record gmr,
                       v_pci                     pci
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and grd.internal_grd_ref_no = prrqs.internal_grd_ref_no
                   and grd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       grd.internal_contract_item_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id in
                       ('pledgeTransfer', 'financialSettlement')
                union
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       pci.contract_type,
                       pci.internal_contract_ref_no internal_contract_ref_no,
                       pci.contract_ref_no contract_ref_no,
                       pci.middle_no contract_middle_no,
                       dgrd.internal_contract_item_ref_no internal_contract_item_ref_no,
                       pci.contract_item_ref_no contract_item_ref_no,
                       pci.pcdi_id pcdi_id,
                       pci.delivery_item_no,
                       pci.del_distribution_item_no,
                       pci.delivery_item_ref_no delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       dgrd.internal_stock_ref_no stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       gmr.gmr_ref_no gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       (prrqs.qty_sign * prrqs.assay_content) assay_content,
                       (prrqs.qty_sign * 0) ext_assay_content,
                       '' assay_finalized,
                       prrqs.due_date
                  from prrqs_prr_qty_status      prrqs,
                       axs_action_summary        axs,
                       pdm_productmaster         pdm,
                       dgrd_delivered_grd        dgrd,
                       gmr_goods_movement_record gmr,
                       v_pci                     pci
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
                   and dgrd.internal_gmr_ref_no = prrqs.internal_gmr_ref_no
                   and pci.internal_contract_item_ref_no =
                       dgrd.internal_contract_item_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'financialSettlement'
                union
                select prrqs.prrqs_id unique_id,
                       prrqs.corporate_id,
                       '' contract_type,
                       '' internal_contract_ref_no,
                       '' contract_ref_no,
                       0 contract_middle_no,
                       '' internal_contract_item_ref_no,
                       '' contract_item_ref_no,
                       '' pcdi_id,
                       '' delivery_item_no,
                       0 del_distribution_item_no,
                       '' delivery_item_ref_no,
                       prrqs.internal_grd_ref_no stock_id,
                       '' stock_ref_no,
                       prrqs.internal_gmr_ref_no internal_gmr_ref_no,
                       '' gmr_ref_no,
                       prrqs.activity_action_id,
                       prrqs.cp_id supplier_id,
                       prrqs.to_cp_id to_supplier_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       (prrqs.qty_sign * prrqs.qty) qty,
                       (prrqs.qty_sign * prrqs.ext_qty) ext_qty,
                       prrqs.qty_unit_id qty_unit_id,
                       axs.internal_action_ref_no,
                       axs.eff_date activity_date,
                       (prrqs.qty_sign * prrqs.assay_content) assay_content,
                       (prrqs.qty_sign * 0) ext_assay_content,
                       '' assay_finalized,
                       prrqs.due_date
                  from prrqs_prr_qty_status prrqs,
                       axs_action_summary   axs,
                       pdm_productmaster    pdm
                 where prrqs.internal_action_ref_no =
                       axs.internal_action_ref_no
                   and prrqs.cp_type = 'Supplier'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and pdm.product_id = prrqs.product_id
                   and prrqs.activity_action_id = 'metalBalanceTransfer') retn_temp
        union
        select prrqs.prrqs_id unique_id,
               prrqs.corporate_id,
               '' contract_type,
               '' internal_contract_ref_no,
               '' contract_ref_no,
               0 contract_middle_no,
               '' internal_contract_item_ref_no,
               '' contract_item_ref_no,
               '' pcdi_id,
               '' delivery_item_no,
               0 del_distribution_item_no,
               '' delivery_item_ref_no,
               dgrd.internal_dgrd_ref_no stock_id,
               dgrd.internal_stock_ref_no stock_ref_no,
               prrqs.internal_gmr_ref_no,
               gmr.gmr_ref_no,
               prrqs.activity_action_id,
               prrqs.cp_id supplier_id,
               prrqs.to_cp_id debt_supplier_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               (prrqs.qty_sign * prrqs.qty) debt_qty,
               (prrqs.qty_sign * prrqs.ext_qty) ext_debt_qty,
               prrqs.qty_unit_id debt_qty_unit_id,
               axs.internal_action_ref_no,
               axs.eff_date activity_date,
               (prrqs.qty_sign * prrqs.assay_content) assay_content,
               (prrqs.qty_sign * 0) ext_assay_content,
               '' assay_finalized,
               prrqs.due_date
          from prrqs_prr_qty_status      prrqs,
               axs_action_summary        axs,
               pdm_productmaster         pdm,
               dgrd_delivered_grd        dgrd,
               gmr_goods_movement_record gmr
         where prrqs.internal_action_ref_no = axs.internal_action_ref_no
           and prrqs.cp_type = 'Supplier'
           and prrqs.is_active = 'Y'
           and prrqs.qty_type = 'Returned'
           and pdm.product_id = prrqs.product_id
           and dgrd.internal_dgrd_ref_no = prrqs.internal_dgrd_ref_no
           and gmr.internal_gmr_ref_no = prrqs.internal_gmr_ref_no) mat_temp,
       axm_action_master axm,
       phd_profileheaderdetails phd,
       phd_profileheaderdetails phd_debt,
       qum_quantity_unit_master qum
 where axm.action_id = mat_temp.activity_action_id
   and phd.profileid = mat_temp.supplier_id
   and phd_debt.profileid(+) = mat_temp.debt_supplier_id
   and qum.qty_unit_id = mat_temp.debt_qty_unit_id
 order by mat_temp.activity_date desc;
/
create or replace view v_in_process_stock_exp as
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
       ips_temp.input_stock_ref_no,
       ips_temp.utility_header_id,
       fmuh.utility_ref_no,
       ips_temp.supp_contract_item_ref_no as supp_int_contract_item_ref_no,
       supp_pci.contract_item_ref_no supp_contract_item_ref_no,
       ips_temp.supp_internal_gmr_ref_no,
       supp_gmr.gmr_ref_no as supp_gmr_ref_no
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
               grd_cloned.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id,
               (case
                 when gmr.is_pass_through = 'Y' then
                  grd_cloned.supp_contract_item_ref_no
                 else
                  ''
               end) supp_contract_item_ref_no,
               (case
                 when gmr.is_pass_through = 'Y' then
                  grd_cloned.supp_internal_gmr_ref_no
                 else
                  ''
               end) supp_internal_gmr_ref_no
          from grd_goods_record_detail      grd,
               grd_goods_record_detail      grd_cloned,
               pdm_productmaster            pdm_consc,
               gmr_goods_movement_record    gmr,
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
           and axs.internal_action_ref_no = grd.first_int_action_ref_no
           and axm.action_id = axs.action_id
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
               grd_parent.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id,
               '' supp_contract_item_ref_no,
               '' supp_internal_gmr_ref_no
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
               agrd_cloned.internal_stock_ref_no input_stock_ref_no,
               grd.utility_header_id as utility_header_id,
               agrd_cloned.supp_contract_item_ref_no,
               agrd_cloned.supp_internal_gmr_ref_no
          from agrd_action_grd              agrd,
               grd_goods_record_detail      grd,
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
           and axs.internal_action_ref_no = agrd.first_int_action_ref_no
           and axs.status = 'Active'
           and axm.action_id = axs.action_id
           and agrd_cloned.internal_grd_ref_no =
               agrd_fm.parent_internal_grd_ref_no
           and agrd_fm.internal_grd_ref_no = agrd.parent_internal_grd_ref_no
           and agrd_cloned.is_deleted = 'N'
           and agrd_cloned.status = 'Active'
           and pdm_consc.product_id = agrd_cloned.product_id
           and grd.internal_grd_ref_no = agrd.internal_grd_ref_no
        
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
        '' input_stock_ref_no,
        '' utility_header_id,
        '' supp_contract_item_ref_no,
        '' supp_internal_gmr_ref_no
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
        ) ips_temp,
       fmuh_free_metal_utility_header fmuh,
       gmr_goods_movement_record supp_gmr,
       v_pci supp_pci
 where ips_temp.utility_header_id = fmuh.fmuh_id(+)
   and ips_temp.supp_internal_gmr_ref_no = supp_gmr.internal_gmr_ref_no(+)
   and ips_temp.supp_contract_item_ref_no =
       supp_pci.internal_contract_item_ref_no(+);
/
set define off;
Update AMC_APP_MENU_CONFIGURATION amc
set AMC.LINK_CALLED = '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=253&ReportName=DailyRealizedPNLReportConc_Cog.rpt.rpt&ExportFormat=HTML&isEodReport=Y'
where AMC.MENU_ID = 'RPT-D253';
commit;

update SCM_SERVICE_CHARGE_MASTER set COST_COMPONENT_NAME = 'Assay Charge' where COST_ID = 'SCM-24';
update SCM_SERVICE_CHARGE_MASTER set COST_COMPONENT_NAME = 'Sampling Charge' where COST_ID = 'SCM-26';


SET DEFINE OFF;
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('EX', 'Exposure', 4, 2, '/metals/loadListOfQuantityExposureProcess.action?method=loadListOfQuantityExposureProcess&gridId=QEP', 
    NULL, 'PE1', NULL, 'Period End', 'APP-PFL-N-193', 
    'N');


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('EX1', 'Quantity Exposure Process', 1, 3, '/metals/loadListOfQuantityExposureProcess.action?method=loadListOfQuantityExposureProcess&gridId=QEP', 
    NULL, 'EX', NULL, 'Period End', NULL, 
    'N');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('EX2', 'FX Exposure Process', 2, 3, '/metals/loadListOfFxExposureProcess.action?method=loadListOfFxExposureProcess&gridId=FXEP', 
    NULL, 'EX', NULL, 'Period End', NULL, 
    'N');


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('QEP', 'List Of Quantity Exposure Process', '[     
  {header: "Process Ref No", width: 150, sortable: true, dataIndex: "processRefNo"},
  {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
  {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},
  {header: "Hedge Correction Events", width: 150, sortable: true, dataIndex: "hedgeCorrectionEvents"},
  {header: "Confirmation Details", width: 150, sortable: true, dataIndex: "confirmationDetails"}
]', NULL, NULL, 
    '[     
    {header: "Process Ref No", width: 150, sortable: true, dataIndex: "processRefNo"},
    {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
    {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},
    {header: "Hedge Correction Events", width: 150, sortable: true, dataIndex: "hedgeCorrectionEvents"},
    {header: "Confirmation Details", width: 150, sortable: true, dataIndex: "confirmationDetails"}
]', NULL, 'periodend/listOfExposureProcess.jsp', '/private/js/periodend/listOfQuantityExposureProcess.js');


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('FXEP', 'List Of Fx Exposure Process', '[     
  {header: "Process Ref No", width: 150, sortable: true, dataIndex: "processRefNo"},
  {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
  {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},
  {header: "Confirmation Details", width: 150, sortable: true, dataIndex: "confirmationDetails"}
]', NULL, NULL, 
    '[     
    {header: "Process Ref No", width: 150, sortable: true, dataIndex: "processRefNo"},
    {header: "Actual Running Date", width: 150, sortable: true, dataIndex: "actualRunningDate"},
    {header: "Run By", width: 150, sortable: true, dataIndex: "runBy"},    
    {header: "Confirmation Details", width: 150, sortable: true, dataIndex: "confirmationDetails"}
]', NULL, 'periodend/listOfExposureProcess.jsp', '/private/js/periodend/listOfFxExposureProcess.js');


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EX2', 'FXEP', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);

 
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EX2_1', 'FXEP', 'Run', 1, 2, 
    NULL, 'function(){loadRun();}', NULL, 'EX2', NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EX1', 'QEP', 'Operation', 1, 1, 
    NULL, NULL, NULL, NULL, NULL);


Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('EX1_1', 'QEP', 'Run', 1, 2, 
    NULL, 'function(){loadRun();}', NULL, 'EX1', NULL);
COMMIT;
alter table PPL_PRICE_PROCESS_LIST add PROCESS_TYPE varchar2(30);

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('FX_EXPOSURE_PROCESS', 'FxProcess', 'Fx Exposure Process', 'N', 'Fx Exposure Process', 
    'Y', NULL);

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('FxExpProcess', 'Fx Exposure Process', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
   BEGIN

for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 

loop

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-FXP-&'||CC.CORPORATE_ID, 'FxExpProcess', CC.CORPORATE_ID, 'FXP-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-FXP-&'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'FX_EXPOSURE_PROCESS', 'FxExpProcess', 'N');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'FX_EXPOSURE_PROCESS', 'FXP-', 0, '-'||CC.CORPORATE_ID);



 end loop;

end;

ALTER TABLE asm_assay_sublot_mapping ADD dry_wet_qty_ratio NUMBER(25,10);

ALTER TABLE sam_stock_assay_mapping ADD  is_output_assay VARCHAR2(1) DEFAULT 'N';
update ASH_ASSAY_HEADER ash
set ASH.PRICING_ASSAY_ASH_ID = TO_CHAR(TO_NUMBER(ASH.ASH_ID)-1)
where ASH.ASSAY_TYPE='Weighted Avg Pricing Assay';

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_PROVISIONAL_ASSAY', 'Assay ', 'Create Provisional Assay', 'Y', 'Create Provisional Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_PROVISIONAL_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('createPARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


 Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_SELF_ASSAY', 'Assay ', 'Create Self Assay', 'Y', 'Create Self Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_SELF_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('createSARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');


  Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_CP_ASSAY', 'Assay ', 'Create CounterParty Assay', 'Y', 'Create CounterParty Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_CP_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('createCPRefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

 

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_UMPIRE_ASSAY', 'Assay ', 'Create Umpire Assay', 'Y', 'Create Umpire Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_UMPIRE_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('createUARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

 Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CREATE_FINAL_ASSAY', 'Assay ', 'Create Final Assay', 'Y', 'Create Final Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CREATE_FINAL_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('createFARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_PROVISIONAL_ASSAY', 'Assay ', 'Cancel Provisional Assay', 'Y', 'Cancel Provisional Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_PROVISIONAL_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('cancelPARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
 


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_SELF_ASSAY', 'Assay ', 'Cancel Self Assay', 'Y', 'Cancel Self Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_SELF_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('cancelSARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_CP_ASSAY', 'Assay ', 'Cancel CounterParty Assay', 'Y', 'Cancel CounterParty Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_CP_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('cancelCPRefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_UMPIRE_ASSAY', 'Assay ', 'Cancel Umpire Assay', 'Y', 'Cancel Umpire Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_UMPIRE_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('cancelUARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');




Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('CANCEL_FINAL_ASSAY', 'Assay ', 'Cancel Final Assay', 'Y', 'Cancel Final Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('CANCEL_FINAL_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('cancelFARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('MODIFY_PROVISIONAL_ASSAY', 'Assay ', 'Modify Provisional Assay', 'Y', 'Modify Provisional Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('MODIFY_PROVISIONAL_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('modifyPARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
 


Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('MODIFY_SELF_ASSAY', 'Assay ', 'Modify Self Assay', 'Y', 'Modify Self Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('MODIFY_SELF_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('modifySARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('MODIFY_CP_ASSAY', 'Assay ', 'Modify CounterParty Assay', 'Y', 'Modify CounterParty Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('MODIFY_CP_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('modifyCPARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('MODIFY_UMPIRE_ASSAY', 'Assay ', 'Modify Umpire Assay', 'Y', 'Modify Umpire Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('MODIFY_UMPIRE_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('modifyUARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');



Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('MODIFY_FINAL_ASSAY', 'Assay ', 'Modify Final Assay', 'Y', 'Modify Final Assay', 
    'N', NULL);
 
  Insert into CAC_CORPORATE_ACTION_CONFIG
   (ACTION_ID, IS_ACCRUAL_POSSIBLE, IS_ESTIMATE_POSSIBLE, EFF_DATE_FIELD, IS_DOC_APPLICABLE, 
    GMR_STATUS_ID, SHIPMENT_STATUS, IS_AFLOAT, IS_INV_POSTING_REQD)
 Values
   ('MODIFY_FINAL_ASSAY', 'Y', 'N', 'activityDate', 'N', 
    '2', 'In Warehouse', 'N', 'N');
    
 Insert into AKM_ACTION_REF_KEY_MASTER
  (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
  ('modifyFARefNo', 'Asy Ref No', 
    'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');

BEGIN
for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 
loop

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CPA-&'||CC.CORPORATE_ID, 'createPARefNo', CC.CORPORATE_ID, 'PA-', 1, 
    0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CPA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_PROVISIONAL_ASSAY', 'createPARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CREATE_PROVISIONAL_ASSAY', 'PA-', 0, '-'||CC.CORPORATE_ID);


   Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CSA-'||CC.CORPORATE_ID, 'createSARefNo', CC.CORPORATE_ID, 'SA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CSA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_SELF_ASSAY', 'createSARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CREATE_SELF_ASSAY', 'SA-', 0, '-'||CC.CORPORATE_ID);

   Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CCPA-'||CC.CORPORATE_ID, 'createCPRefNo', CC.CORPORATE_ID, 'CCPA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CCPA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_CP_ASSAY', 'createCPRefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CREATE_CP_ASSAY', 'CCPA-', 0, '-'||CC.CORPORATE_ID);


   Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CUA-'||CC.CORPORATE_ID, 'createUARefNo', CC.CORPORATE_ID, 'CUA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CUA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_UMPIRE_ASSAY', 'createUARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CREATE_UMPIRE_ASSAY', 'CUA-', 0, '-'||CC.CORPORATE_ID);

   Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-CFA-'||CC.CORPORATE_ID, 'createFARefNo', CC.CORPORATE_ID, 'CFA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-CFA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CREATE_FINAL_ASSAY', 'createFARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CREATE_FINAL_ASSAY', 'CFA-', 0, '-'||CC.CORPORATE_ID);
   
   
  Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-DPA-'||CC.CORPORATE_ID, 'cancelPARefNo', CC.CORPORATE_ID, 'DPA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-DPA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_PROVISIONAL_ASSAY', 'cancelPARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_PROVISIONAL_ASSAY', 'DPA-', 0, '-'||CC.CORPORATE_ID);

  
  Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-DSA-'||CC.CORPORATE_ID, 'cancelSARefNo', CC.CORPORATE_ID, 'DSA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-DSA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_SELF_ASSAY', 'cancelSARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_SELF_ASSAY', 'DSA-', 0, '-'||CC.CORPORATE_ID);


Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-DCPA-'||CC.CORPORATE_ID, 'cancelCPRefNo', CC.CORPORATE_ID, 'DCPA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-DCPA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_CP_ASSAY', 'cancelCPRefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_CP_ASSAY', 'DCPA-', 0, '-'||CC.CORPORATE_ID);
   
  
Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-DUA-'||CC.CORPORATE_ID, 'cancelUARefNo', CC.CORPORATE_ID, 'DUA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-DUA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_UMPIRE_ASSAY', 'cancelUARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_UMPIRE_ASSAY', 'DUA-', 0, '-'||CC.CORPORATE_ID);
   
   
 Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-DFA-'||CC.CORPORATE_ID, 'cancelFARefNo', CC.CORPORATE_ID, 'DFA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-DFA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'CANCEL_FINAL_ASSAY', 'cancelFARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'CANCEL_FINAL_ASSAY', 'DFA-', 0, '-'||CC.CORPORATE_ID);
   
 
 Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-MPA-'||CC.CORPORATE_ID, 'modifyPARefNo', CC.CORPORATE_ID, 'MPA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-MPA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'MODIFY_PROVISIONAL_ASSAY', 'modifyPARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'MODIFY_PROVISIONAL_ASSAY', 'MPA-', 0, '-'||CC.CORPORATE_ID);
   
   
 Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-MSA-'||CC.CORPORATE_ID, 'modifySARefNo', CC.CORPORATE_ID, 'MSA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-MSA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'MODIFY_SELF_ASSAY', 'modifySARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'MODIFY_SELF_ASSAY', 'MSA-', 0, '-'||CC.CORPORATE_ID);
   
   
Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-MCPA-'||CC.CORPORATE_ID, 'modifyCPARefNo', CC.CORPORATE_ID, 'MCPA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-MCPA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'MODIFY_CP_ASSAY', 'modifyCPARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'MODIFY_CP_ASSAY', 'MCPA-', 0, '-'||CC.CORPORATE_ID);
   
   
   
Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-MUA-'||CC.CORPORATE_ID, 'modifyUARefNo', CC.CORPORATE_ID, 'MUA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-MUA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'MODIFY_UMPIRE_ASSAY', 'modifyUARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'MODIFY_UMPIRE_ASSAY', 'MUA-', 0, '-'||CC.CORPORATE_ID);
   
      
Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-MFA-'||CC.CORPORATE_ID, 'modifyFARefNo', CC.CORPORATE_ID, 'MFA-', 1, 0, '-'||CC.CORPORATE_ID, 1, 'N');

 Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-MFA-'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'MODIFY_FINAL_ASSAY', 'modifyFARefNo', 'N');

 Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'MODIFY_FINAL_ASSAY', 'MFA-', 0, '-'||CC.CORPORATE_ID);
   
    end loop;
end;
/

UPDATE asm_assay_sublot_mapping asm
   SET asm.dry_wet_qty_ratio = (asm.dry_weight / asm.net_weight) * 100
 WHERE asm.ash_id IN (
          SELECT ash.ash_id
            FROM ash_assay_header ash, asm_assay_sublot_mapping asm
           WHERE asm.ash_id = ash.ash_id
             AND asm.dry_weight IS NOT NULL
             AND asm.is_active = 'Y'
             AND ash.is_active = 'Y');
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
                              -- pofh.qty_to_be_fixed,
                               (case
                                 when pocd.qp_period_type = 'Event' then
                                  cur_pcdi_rows.item_qty
                                 else
                                  pofh.qty_to_be_fixed
                               end) qty_to_be_fixed,
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
                              and nvl(pfd.is_hedge_correction, 'N') = 'N'
                              and nvl(pfd.user_price, 0) <> 0
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
                      and nvl(pfd.is_hedge_correction, 'N') = 'N'
                      and nvl(pfd.user_price, 0) <> 0
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
         and ceqs.element_id = pc_element_id
         and pcpd.input_output ='Input';
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
                              -- pofh.qty_to_be_fixed,
                               (case
                                 when pocd.qp_period_type = 'Event' then
                                  cur_pcdi_rows.item_qty
                                 else
                                  pofh.qty_to_be_fixed
                               end) qty_to_be_fixed,
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
                              and nvl(pfd.is_hedge_correction, 'N') = 'N'
                              and nvl(pfd.user_price, 0) <> 0
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
                        and nvl(pfd.is_hedge_correction, 'N') = 'N'
                        and nvl(pfd.user_price, 0) <> 0
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
SET DEFINE OFF;
delete from AMC_APP_MENU_CONFIGURATION amc where AMC.MENU_ID='RPT-D257';
delete from RPC_RF_PARAMETER_CONFIG rpc where RPC.REPORT_ID='257';
delete from RFC_REPORT_FILTER_CONFIG rfc where RFC.REPORT_ID='257';
delete from REF_REPORTEXPORTFORMAT ref where REF.REPORT_ID in('257','243');
delete from RML_REPORT_MASTER_LIST rml where RML.REPORT_ID ='257';
commit;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('257', '31', 'MonthlyContractStatusReport.rpt', 'Monthly Contract Status Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');

Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D257', 'Monthly Contract Status Report', 23, 5, 

'/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=257&ReportName=MonthlyContractStatusReport.rp

t&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
commit;

begin
----Fpr RFC
for cc in  (select AK.CORPORATE_ID from AK_CORPORATE ak) loop
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 1, 1, 
    'Year', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 1, 2, 
    'Month', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 1, 4, 
    'Invoice Pay-in Currency', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 1, 3, 
    'Counter Party', 'GFF1001', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 1, 5, 
    'Contract Ref No', 'GFF10206', 1, 'N');        
----For RPC
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1060', 'MonthList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1061', 'Month');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1060', 'yearList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1061', 'Year');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1001', 'businesspartner');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1002', 'CounterParty');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1003', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1004', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1005', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1006', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1008', 'BUYER,SELLER');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 'RFP100533', 'ContractRefNo');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1045', 'currencylist');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1046', 'InvoicePayInCurrency');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1050', '1'); 
---For REF
end loop;
commit;
end;
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('257', 'EXCEL', 'MonthlyContractStatusReport_Excel.rpt');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('243', 'EXCEL', 'ContractStatusReport_Excel.rpt');   
COMMIT;
SET DEFINE OFF;

delete from AMC_APP_MENU_CONFIGURATION where menu_id='CDC-MM-9';

delete from AMC_APP_MENU_CONFIGURATION where menu_id='CDC-P7';


Insert into  AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('P_PROCESS', 'Pricing Process', 5, 2, '/metals/loadPeriodEndPricing.action', 
    NULL, 'PE1', NULL, 'Period End', 'APP-PFL-N-193', 
    'N');

Insert into  AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('CDC-MM-9', 'New', 1, 3, '/metals/loadPeriodEndPricing.action', 
    NULL, 'P_PROCESS', NULL, 'Period End', NULL, 
    'N');

Insert into  AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('CDC-P7', 'List All', 2, 3, '/metals/loadListOfPriceProcess.action?gridId=LOPP', 
    NULL, 'P_PROCESS', NULL, 'Period End', NULL, 
    'N');

COMMIT;
alter table HCD_HEDGE_CORRECTION_DETAILS drop column EVENT_SEQUENC_NO;
alter table HCD_HEDGE_CORRECTION_DETAILS add EVENT_SEQUENC_NO number(25,10);
alter table HCD_HEDGE_CORRECTION_DETAILS add IS_HEDGE_CORRECTION_POSTED CHAR(1 char);

ALTER TABLE HCD_HEDGE_CORRECTION_DETAILS ADD (
  CONSTRAINT PK_HCD
 PRIMARY KEY
 (HCD_ID));

create table HQPM_HEDGE_QTY_PROCESS_MAPPING
(
  HQP_ID varchar(30),
  HCD_ID varchar(15),
  PRICE_PROCESS_ID varchar(30),
  IS_ACTIVE CHAR(1 char),
  VERSION NUMBER(10)
  
);
CREATE UNIQUE INDEX PK_HQPM ON HQPM_HEDGE_QTY_PROCESS_MAPPING
(HQP_ID);
CREATE INDEX IDX_FK_HQPM_HCD_ID ON HQPM_HEDGE_QTY_PROCESS_MAPPING
(HCD_ID);
CREATE INDEX IDX_FK_HQPM_PRICE_PROCESS_ID ON HQPM_HEDGE_QTY_PROCESS_MAPPING
(PRICE_PROCESS_ID);

ALTER TABLE HQPM_HEDGE_QTY_PROCESS_MAPPING ADD (
  CONSTRAINT PK_HQPM
 PRIMARY KEY
 (HQP_ID));
 ALTER TABLE HQPM_HEDGE_QTY_PROCESS_MAPPING ADD (
  CONSTRAINT FK_HQPM_HCD_ID 
 FOREIGN KEY (HCD_ID) 
 REFERENCES HCD_HEDGE_CORRECTION_DETAILS(HCD_ID));
 
 ALTER TABLE HQPM_HEDGE_QTY_PROCESS_MAPPING ADD (
  CONSTRAINT FK_HQPM_PRICE_PROCESS_ID 
 FOREIGN KEY (PRICE_PROCESS_ID) REFERENCES PPL_PRICE_PROCESS_LIST (PRICE_PROCESS_ID));

CREATE SEQUENCE SEQ_HQPM
MINVALUE 10
START WITH 10
INCREMENT BY 1;
 


alter table PFD_PRICE_FIXATION_DETAILS add event_sequence_no number(25,10);

alter table POFHL_PRICE_OPT_FIXAT_HEAD_LOG add HEDGE_CORRECTION_QTY_DELTA number(25,10);
alter table POFHL_PRICE_OPT_FIXAT_HEAD_LOG add QP_START_QTY_DELTA number(25,10);
alter table POFHL_PRICE_OPT_FIXAT_HEAD_LOG add IS_PROVESIONAL_ASSAY_EXIST CHAR(1 CHAR);
alter table POFHL_PRICE_OPT_FIXAT_HEAD_LOG add BALANCE_PRICED_QTY_DELTA number(25,10);
alter table POFHL_PRICE_OPT_FIXAT_HEAD_LOG add PER_DAY_HEDGE_CORR_QTY_DELTA number(25,10);
alter table POFHL_PRICE_OPT_FIXAT_HEAD_LOG add TOTAL_HEDGE_CORRE_QTY_DELTA number(25,10);


ALTER TABLE PCBPD_PC_BASE_PRICE_DETAIL
 ADD (IS_FX_BY_REQUEST  CHAR(1 CHAR));

ALTER TABLE PCBPDUL_PC_BASE_PRICE_DTL_UL
 ADD (IS_FX_BY_REQUEST  CHAR(1 CHAR));

ALTER TABLE PFD_PRICE_FIXATION_DETAILS
 ADD (IS_FX_BY_REQUEST  CHAR(1 CHAR));
ALTER TABLE YPD_YIELD_PCT_DETAIL MODIFY(YIELD_PCT NUMBER(10,4));
DROP SNAPSHOT LOG ON  YPD_YIELD_PCT_DETAIL;
CREATE MATERIALIZED VIEW LOG ON  YPD_YIELD_PCT_DETAIL;

declare
fetchqry1 clob :='INSERT INTO IS_D(
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
INTERNAL_COMMENTS,
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
INVS.INTERNAL_COMMENTS,
cm_pct.cur_code,
t.DRY,
t.WET';

BEGIN

 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-PIC','DGM-FIC','DGM-DFIC') AND IS_CONCENTRATE = 'Y';
 commit;
  

END;

CREATE MATERIALIZED VIEW LOG ON  PSR_POOL_STOCK_REGISTER;
CREATE MATERIALIZED VIEW LOG ON  PM_POOL_MASTER;
delete from rpc_rf_parameter_config rpc where rpc.report_id = 256;
delete from rfc_report_filter_config rfc where rfc.report_id = 256;
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D256';
delete from rml_report_master_list rml where rml.report_id = 256;
update amc_app_menu_configuration amc
set amc.menu_display_name = 'Monthly Arrival Report'
where amc.menu_id = 'RPT-D255';
commit;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('256', '31', 'MonthlyFeedConsumptionReport.rpt', 'Monthly Feed Consumption Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D256', 'Monthly Feed Consumption Report', 23, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=256&ReportName=MonthlyFeedConsumptionReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
COMMIT;

SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
loop
    dbms_output.put_line(cc.corporate_id);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY03', 1, 3, 
    'Smelter', 'GFF1001', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 1, 1, 
    'Year', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY04', 1, 5, 
    'Report Type', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY05', 1, 6, 
    'Product', 'GFF1011', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY06', 1, 7, 
    'Quality', 'GFF1011', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY02', 1, 2, 
    'Month', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY08', 1, 4, 
    'Report Data', 'GFF1012', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY08', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY08', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY08', 'RFP1060', 'ReportDataList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY08', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY08', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY08', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY08', 'RFP1061', 'ReportData');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY02', 'RFP1060', 'MonthList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY02', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY02', 'RFP1061', 'Month');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY02', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY02', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY02', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY02', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP1060', 'yearList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP1061', 'Year');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY04', 'RFP1060', 'reportList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY04', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY04', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY04', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY04', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY04', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY04', 'RFP1061', 'ReportType');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY05', 'RFP1045', 'allProducts');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY05', 'RFP1046', 'Product');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY05', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY05', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY05', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY05', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY05', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY06', 'RFP1045', 'quality');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY06', 'RFP1046', 'Quality');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY06', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY06', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY06', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY06', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY06', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY03', 'RFP1001', 'businesspartner');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY03', 'RFP1002', 'Arrival');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY03', 'RFP1003', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY03', 'RFP1004', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY03', 'RFP1005', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY03', 'RFP1006', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY03', 'RFP1008', 'WAREHOUSING');
COMMIT;
  end loop;
commit;
end;
declare
fetchqry1 clob :='INSERT INTO IS_D(
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
INTERNAL_COMMENTS,
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
'''' as ORIGIN,
PCI.TERMS as INCO_TERM_LOCATION,
'''' as NOTIFY_PARTY, 
PCI.CONTRACT_TYPE as SALES_PURCHASE,
INVS.INVOICE_STATUS as INVOICE_STATUS,
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
PCI.TERMS,
QUM_GMR.QTY_UNIT,
PCI.CONTRACT_TYPE,
INVS.AMOUNT_TO_PAY_BEFORE_ADJ,
INVS.INVOICE_STATUS,
INVS.INTERNAL_COMMENTS,
cm_pct.cur_code,
t.DRY,
t.WET';

BEGIN

 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID IN ('DGM-PIC','DGM-FIC','DGM-DFIC') AND IS_CONCENTRATE = 'Y';
 commit;
  

END;
create or replace view v_list_of_gmr_new as
select gmr.corporate_id,
       cp.contract_ref_no contract_ref_no,
       gmr.trucking_receipt_no trucking_receipt_no,
       gmr.rail_receipt_no rail_receipt_no,
       to_char(gmr.trucking_receipt_date, 'dd-Mon-yyyy') trucking_receipt_date,
       to_char(gmr.rail_receipt_date, 'dd-Mon-yyyy') rail_receipt_date,
       axs.action_id,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no activity_ref_no,
       gmr.warehouse_receipt_no warehouse_receipt_no,
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
       gmr.status_id,
       gsm.status status,
       gmr.inventory_status is_title_transfered,
       (select vcd.vessel_name
          from vcd_vessel_creation_detail vcd
         where vcd.vessel_id = vd.vessel_id) vessel_name,
       gmr.gmr_latest_action_action_id latest_action_id,
       (select axm.action_name
          from axm_action_master axm
         where axm.action_id = gmr.gmr_latest_action_action_id) latest_action_name,
       axm.action_name first_action_name,
       axs.action_ref_no,
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
       cp.contract_item_ref_no item_nos,
       nvl(gmr.tt_in_qty, 0) tt_in_qty,
       nvl(gmr.tt_out_qty, 0) tt_out_qty,
       nvl(gmr.tt_none_qty, 0) tt_none_qty,
       vd.vessel_voyage_name,
       vd.booking_ref_no,
       gmr.internal_contract_ref_no,
       bl_details.bl_no bl_no,
       bl_details.bl_date bl_date,
       gmr.created_date,
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
       gsm_gmr_stauts_master gsm,
       qum_quantity_unit_master qum,
       axm_action_master axm,
       phd_profileheaderdetails phd_warehouse,
       sld_storage_location_detail sld,
       vd_voyage_detail vd,
       (select gcim.internal_gmr_ref_no internal_gmr_ref_no,
               f_string_aggregate(pci.contract_ref_no) contract_ref_no,
               f_string_aggregate(pci.cp_id) contract_party_profile_id,
               f_string_aggregate(pci.cp_name) as cp_name,
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
/
Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('AFD-OP', 'LOAFD', 'Operations', 2, 1, NULL, 'function(){}', NULL, NULL, NULL);

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('AFD-WNS', 'LOAFD', 'Modify Weighing And Sampling', 6, 2, 
    'APP-PFL-N-160', 'function(){modifyWnsAssay()}', NULL, 'AFD-OP', NULL);
/
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('255', '31', 'MonthlyRealizedPNLReport.rpt', 'Monthly Realized PNL Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOD', 'Y');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D255', 'Monthly Realized PNL Report', 22, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOD&ReportID=255&ReportName=MonthlyRealizedPNLReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', '', 'Reports', '', 
    'N');

BEGIN
FOR CC IN ( SELECT * FROM AK_CORPORATE AKC WHERE AKC.IS_ACTIVE = 'Y' AND AKC.IS_INTERNAL_CORPORATE = 'N')

LOOP
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   ( CC.CORPORATE_ID , '255', 'RFC255PHY01', 1, 1, 
    'EOM Month', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 1, 3, 
    'Profit Center', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY04', 1, 2, 
    'EOM Year', 'GFF1012', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY01', 'RFP1061', 'Month');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY01', 'RFP1060', 'MonthList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY01', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY01', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY01', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY01', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY01', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 'RFP1045', 'reportProfitcenterList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 'RFP1046', 'ProfitCenter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY02', 'RFP1053', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY04', 'RFP1060', 'yearList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY04', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY04', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY04', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY04', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY04', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (CC.CORPORATE_ID, '255', 'RFC255PHY04', 'RFP1061', 'Year');

END LOOP;

END;
--List of Fx Exposure

INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url, default_record_model_state, other_url,
             screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('LOFE', 'List of FX Exposure',
             '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\"></div>","hideable":false,"id":"checker","sortable":false,"width":20},
   {"dataIndex":"product","header":"Product","id":1,"sortable":true,"width":150},
   {"dataIndex":"priceFixationRefNo","header":"Price Fixation Ref.No.","id":2,"sortable":true,"width":150},
   {"dataIndex":"contractType","header":"Contract Type","id":3,"sortable":true,"width":150},
   {"dataIndex":"deliveryItemRefNo","header":"Dl Ref.No.","id":4,"sortable":true,"width":150},
   {"dataIndex":"profitCenter","header":"Profit Center","id":5,"sortable":true,"width":150},
   {"dataIndex":"priceFixationDate","header":"Price Fixation Date","id":6,"sortable":true,"width":150},
   {"dataIndex":"price","header":"Price","id":7,"sortable":true,"width":150},
   {"dataIndex":"qpPeriod","header":"QP Period","id":8,"sortable":true,"width":150},
   {"dataIndex":"qtyPriced","header":"Qty.Priced","id":9,"sortable":true,"width":150},
   {"dataIndex":"gmrAllocatedQty","header":"GMR Allocated Qty.","id":10,"sortable":true,"width":150},
   {"dataIndex":"cpName","header":"CP Name","id":11,"sortable":true,"width":150},
   {"dataIndex":"deliveryItemPeriod","header":"Dl Period","id":12,"sortable":true,"width":150},
   {"dataIndex":"hedgeAllocationStatus","header":"Hedge Allocation Status","id":13,"sortable":true,"width":150},
   {"dataIndex":"hedgeAmount","header":"Hedge Amount","id":13,"sortable":true,"width":150},
   {"dataIndex":"fXCorrectionDate","header":"FX Correction Date","id":13,"sortable":true,"width":150},
   {"dataIndex":"fXFixationDate","header":"FX Fixation Date","id":13,"sortable":true,"width":150}]',
             NULL, '/metals/loadListOfFXExposure.action', '[', NULL,
             'physical/derivative/listing/listOfFXExposure.jsp',
             '/private/js/physical/derivative/listing/listOfFXExposure.js'
            );
            
            
INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called, icon_class,
             menu_parent_id, acl_id, tab_id, FEATURE_ID, is_deleted
            )
     VALUES ('MINING_LOFE', 'List of FX Exposure', '5', '3',
             '/metals/loadListOfFXExposure.action?gridId=LOFE', NULL,
             'PE1.3', NULL, 'Period End', 'APP-PFL-N-196','N'
            );

INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('LOFE_1', 'LOFE', 'Operation', '1',
             '1', NULL, NULL, NULL,
             NULL, NULL
            );

INSERT INTO gmc_grid_menu_configuration
            (menu_id, grid_id, menu_display_name, display_seq_no,
             menu_level_no, FEATURE_ID, link_called, icon_class,
             menu_parent_id, acl_id
            )
     VALUES ('LOFE_2', 'LOFE', 'Allocate Hedge', '1',
             '2', NULL, NULL, NULL,
             NULL, NULL
            );


--delete Generate Contract Document,Mark as closed, update Cost&Valuation
delete from GMC_GRID_MENU_CONFIGURATION gmc where GMC.MENU_ID='MIN_1_6';
delete from GMC_GRID_MENU_CONFIGURATION gmc where GMC.MENU_ID='MIN_1_7'; 
delete from GMC_GRID_MENU_CONFIGURATION gmc where GMC.MENU_ID='MIN_1_8';


INSERT INTO axm_action_master
            (action_id, entity_id, action_name, is_new_gmr_applicable,
             action_desc, is_generate_doc_applicable, is_ref_no_gen_applicable
            )
     VALUES ('MODIFY_WNS_ASSAY', 'WS Assay ', 'Modify WS Assay', 'Y',
             'Modify WS Assay', 'N', NULL
            );

INSERT INTO cac_corporate_action_config
            (action_id, is_accrual_possible, is_estimate_possible,
             eff_date_field, is_doc_applicable, gmr_status_id,
             shipment_status, is_afloat, is_inv_posting_reqd
            )
     VALUES ('MODIFY_WNS_ASSAY', 'Y', 'N',
             'activityDate', 'N', '2',
             'In Warehouse', 'N', 'N'
            );
create or replace view v_list_of_gmr_new as
select gmr.corporate_id,
       cp.contract_ref_no contract_ref_no,
       gmr.trucking_receipt_no trucking_receipt_no,
       gmr.rail_receipt_no rail_receipt_no,
       to_char(gmr.trucking_receipt_date, 'dd-Mon-yyyy') trucking_receipt_date,
       to_char(gmr.rail_receipt_date, 'dd-Mon-yyyy') rail_receipt_date,
       axs.action_id,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no activity_ref_no,
       gmr.warehouse_receipt_no warehouse_receipt_no,
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
       gmr.status_id,
       gsm.status status,
       gmr.inventory_status is_title_transfered,
       (select vcd.vessel_name
          from vcd_vessel_creation_detail vcd
         where vcd.vessel_id = vd.vessel_id) vessel_name,
       gmr.gmr_latest_action_action_id latest_action_id,
       (select axm.action_name
          from axm_action_master axm
         where axm.action_id = gmr.gmr_latest_action_action_id) latest_action_name,
       axm.action_name first_action_name,
       axs.action_ref_no,
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
       cp.contract_item_ref_no item_nos,
       nvl(gmr.tt_in_qty, 0) tt_in_qty,
       nvl(gmr.tt_out_qty, 0) tt_out_qty,
       nvl(gmr.tt_none_qty, 0) tt_none_qty,
       vd.vessel_voyage_name,
       vd.booking_ref_no,
       gmr.internal_contract_ref_no,
       bl_details.bl_no bl_no,
       bl_details.bl_date bl_date,
       gmr.created_date,
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
       gsm_gmr_stauts_master gsm,
       qum_quantity_unit_master qum,
       axm_action_master axm,
       phd_profileheaderdetails phd_warehouse,
       sld_storage_location_detail sld,
       vd_voyage_detail vd,
       (select gcim.internal_gmr_ref_no internal_gmr_ref_no,
               f_string_aggregate(pci.contract_ref_no) contract_ref_no,
               f_string_aggregate(pci.cp_id) contract_party_profile_id,
               f_string_aggregate(pci.cp_name) as cp_name,
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
/

Insert into AXM_ACTION_MASTER
   (ACTION_ID, ENTITY_ID, ACTION_NAME, IS_NEW_GMR_APPLICABLE, ACTION_DESC, 
    IS_GENERATE_DOC_APPLICABLE, IS_REF_NO_GEN_APPLICABLE)
 Values
   ('QTY_EXPOSURE_PROCESS', 'QtyProcess', 'Qty Exposure Process', 'N', 'Qty Exposure Process', 
    'Y', NULL);

Insert into AKM_ACTION_REF_KEY_MASTER
   (ACTION_KEY_ID, ACTION_KEY_DESC, VALIDATION_QUERY)
 Values
   ('QtyExpProcess', 'Qty Exposure Process', 'SELECT COUNT(*) FROM   AXS_ACTION_SUMMARY axs WHERE  axs.action_ref_no = :pc_action_ref_no AND    axs.corporate_id = :pc_corporate_id');
   
   BEGIN

for cc in (select AKC.CORPORATE_ID from AK_CORPORATE akc where AKC.IS_ACTIVE='Y' and AKC.IS_INTERNAL_CORPORATE='N') 

loop

Insert into ARF_ACTION_REF_NUMBER_FORMAT
   (ACTION_REF_NUMBER_FORMAT_ID, ACTION_KEY_ID, CORPORATE_ID, PREFIX, MIDDLE_NO_START_VALUE, 
    MIDDLE_NO_LAST_USED_VALUE, SUFFIX, VERSION, IS_DELETED)
 Values
   ('ARF-QEP-&'||CC.CORPORATE_ID, 'QtyExpProcess', CC.CORPORATE_ID, 'QEP-', 1, 
    0,  '-'||CC.CORPORATE_ID, 1, 'N');

Insert into ARFM_ACTION_REF_NO_MAPPING
   (ACTION_REF_NO_MAPPING_ID, CORPORATE_ID, ACTION_ID, ACTION_KEY_ID, IS_DELETED)
 Values
   ('ARFM-QEP-&'||CC.CORPORATE_ID, CC.CORPORATE_ID, 'QTY_EXPOSURE_PROCESS', 'QtyExpProcess', 'N');

Insert into ERC_EXTERNAL_REF_NO_CONFIG
   (CORPORATE_ID, EXTERNAL_REF_NO_KEY, PREFIX, MIDDLE_NO_LAST_USED_VALUE, SUFFIX)
 Values
   (CC.CORPORATE_ID, 'QTY_EXPOSURE_PROCESS', 'QEP-', 0, '-'||CC.CORPORATE_ID);



 end loop;

end;
SET DEFINE OFF;
update GM_GRID_MASTER set DEFAULT_COLUMN_MODEL_STATE=
   '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},     
                                  {header: "Lot No.", width: 150, sortable: true, dataIndex: "lotNo"},
                                  {header: "Counter Party", width: 150, sortable: true, dataIndex: "counterParty"},
                                  {header: "No.Of SubLots", width: 150, sortable: true, dataIndex: "noOfSubLots"},
                                  {header: "Assay Ref. No.", width: 150, sortable: true, dataIndex: "assayRefNo"},
                                  {header: "Assay Type", width: 150, sortable: true, dataIndex: "assayType"},
                                  {header: "Assay Fully Finalized", width: 150, sortable: true, dataIndex: "assayFullyFinalized"},
                                  {header: "Use For Assay Exchange", width: 150, sortable: true, dataIndex: "useForFinalization"},
                                  {header: "Weighing & Sampling Ref No.", width: 150, sortable: true, dataIndex: "weighingAndSamplingRefNo"},
                                  {header: "Assay Details", width: 150, sortable: true, dataIndex: "assayDetails"},
                                  {header: "Wet Weight", width: 150, sortable: true, dataIndex: "wetWeight"},
                                  {header: "Dry Weight", width: 150, sortable: true, dataIndex: "dryWeight"},
                                  {header: "Assayer/Umpire", width: 150, sortable: true, dataIndex: "assayer"},
                                  {header: "Product", width: 150, sortable: true, dataIndex: "product"},
                                  {header: "Quality", width: 150, sortable: true, dataIndex: "Quality"},
                                  {header: "GMR Ref. No.", width: 150, sortable: true, dataIndex: "gmrRefNo"},
                                  {header: "GMR Activity Ref. No.", width: 150, sortable: true, dataIndex: "gmrActivityRefNo"},
                                  {header: "Contract Item No.", width: 150, sortable: true, dataIndex: "contractItemNo"},
                                  {header: "Delivery Item No.", width: 150, sortable: true, dataIndex: "deliveryItemNo"},
                                  {header: "Used for Pricing", width: 150, sortable: true, dataIndex: "usedForPricing"},
                                  {header: "Activity Date", width: 150, sortable: true, dataIndex: "activityDate"},
                                  {header: "Activity Type", width: 150, sortable: true, dataIndex: "activityType"},
                                  {header: "Used for Invoice.", width: 150, sortable: true, dataIndex: "usedForInvoice"}                         
                              ]', 
    DEFAULT_RECORD_MODEL_STATE='[
                    {name: "lotNo", mapping: "lotNo"},
                    {name: "counterParty", mapping: "counterParty"},
                    {name: "noOfSubLots", mapping: "noOfSubLots"},
                    {name: "assayRefNo", mapping: "assayRefNo"},
                    {name: "assayType", mapping: "assayType"},
                    {name: "assayFullyFinalized", mapping: "assayFullyFinalized"}, 
                    {name: "useForFinalization", mapping: "useForFinalization"},
                    {name: "weighingAndSamplingRefNo", mapping: "weighingAndSamplingRefNo"},
                    {name: "assayDetails", mapping: "assayDetails"},  
                    {name: "wetWeight", mapping: "wetWeight"},
                    {name: "dryWeight", mapping: "dryWeight"},
                    {name: "assayer", mapping: "assayer"},
                    {name: "product", mapping: "product"}, 
                    {name: "Quality", mapping: "Quality"},
                    {name: "gmrRefNo", mapping: "gmrRefNo"},
                    {name: "gmrActivityRefNo", mapping: "gmrActivityRefNo"},  
                    {name: "contractItemNo", mapping: "contractItemNo"},
                    {name: "deliveryItemNo", mapping: "deliveryItemNo"},
                    {name: "usedForPricing", mapping: "usedForPricing"},
                    {name: "activityDate", mapping: "activityDate"}, 
                    {name: "activityType", mapping: "activityType"},
                    {name: "usedForInvoice", mapping: "usedForInvoice"}
                  ]'
where GRID_ID='LOAD';


SET DEFINE OFF;
update DGM_DOCUMENT_GENERATION_MASTER set FETCH_QUERY=
    'INSERT INTO AS_ASSAY_D(
INTERNAL_CONTRACT_ITEM_REF_NO,
ASSAY_REFNO,
INTERNAL_GMR_REF_NO ,
CONTRACT_TYPE       ,
ACTIVITY_DATE      ,
ship_land_date ,
BUYER               ,
SELLER            ,
OUR_CONTRACT_REF_NO ,
CP_CONTRACT_REF_NO ,
GMR_REF_NO         ,
SHIPMENT_DATE      ,
WEIGHING_AND_SAMPLING_REF_NO  ,
PRODUCT_AND_QUALITY ,
ASSAYER      ,
ASSAY_TYPE     ,
EXCHANGE_OF_ASSAYS ,
LOT_NO      ,
NO_OF_SUBLOTS,
CONSOLIDATED_GROUP_ID,
INTERNAL_DOC_REF_NO 
)
SELECT VPCI.INTERNAL_CONTRACT_ITEM_REF_NO AS INTERNAL_CONTRACT_ITEM_REF_NO,
       ASH.ASSAY_REF_NO AS ASSAY_REFNO,
       ASH.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
       GMR.CONTRACT_TYPE AS CONTRACT_TYPE,AXS.EFF_DATE AS ACTIVITY_DATE,
       (CASE
           WHEN ash.assay_type = ''Provisional Assay''
              THEN (SELECT vd.loading_date
                      FROM vd_voyage_detail vd
                     WHERE vd.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
           ELSE (CASE
                    WHEN (SELECT agmr.action_no AS actionno
                            FROM agmr_action_gmr agmr
                           WHERE agmr.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                             AND agmr.is_deleted = ''N''
                             AND agmr.is_final_weight = ''Y'') = 1
                       THEN (SELECT vd.loading_date
                               FROM vd_voyage_detail vd
                              WHERE vd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                    ELSE (SELECT wrd.storage_date
                            FROM wrd_warehouse_receipt_detail wrd
                           WHERE wrd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                 END
                )
        END
       ) ship_land_date,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Sales''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) BUYER,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Purchase''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) SELLER,
       VPCI.CONTRACT_REF_NO AS OUR_CONTRACT_REF_NO,
       VPCI.CP_CONTRACT_REF_NO AS CP_CONTRACT_REF_NO,
       GMR.GMR_REF_NO AS GMR_REF_NO, GMR.EFF_DATE AS SHIPMENT_DATE,
       (SELECT ASH1.ASSAY_REF_NO
          FROM ASH_ASSAY_HEADER ASH1
         WHERE ASH1.ASSAY_TYPE =
                   ''Weighing and Sampling Assay''
           AND ASH1.IS_ACTIVE = ''Y''
           AND nvl(ASH1.IS_DELETE,''N'') = ''N'' 
           AND ASH1.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
           AND ASH1.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
           AND ASH1.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)
                                                 WEIGHING_AND_SAMPLING_REF_NO,
        (VPCI.PRODUCT_NAME
           || '' , ''
           || VPCI.QUALITY_NAME
       ) PRODUCT_AND_QUALITY,
       BGM.BP_GROUP_NAME as ASSAYER,
       ASH.ASSAY_TYPE AS ASSAY_TYPE,
       ASH.USE_FOR_FINALIZATION AS EXCHANGE_OF_ASSAYS, ASH.LOT_NO AS LOT_NO,
       ASH.NO_OF_SUBLOTS AS NO_OF_SUBLOTS,ASH.CONSOLIDATED_GROUP_ID AS CONSOLIDATED_GROUP_ID,?
  FROM ASH_ASSAY_HEADER ASH,
       AXS_ACTION_SUMMARY AXS,
       V_PCI VPCI,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       BGM_BP_GROUP_MASTER bgm
 WHERE ASH.INTERNAL_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
   AND ASH.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND GMR.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND ASH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND BGM.BP_GROUP_ID(+) = ASH.ASSAYER
  AND ASH.ASH_ID = ?'
  where DGM_ID='DGM-AS' and DOC_ID='CREATE_ASSAY';

ALTER TABLE GMR_GOODS_MOVEMENT_RECORD ADD
(
PRODUCT_ID                  VARCHAR2(15),
CONSTRAINT FK_GMR_PRODUCT_ID FOREIGN KEY (PRODUCT_ID) REFERENCES PDM_PRODUCTMASTER (PRODUCT_ID)
);

ALTER TABLE GMRUL_GMR_UL ADD
(
PRODUCT_ID                  VARCHAR2(15)
);

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('RECORD_OUT_PUT_TOLLING', 'Receive Material');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('CREATE_FREE_MATERIAL', 'Capture Yield');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('MARK_FOR_TOLLING', 'Mark For Tolling');



Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'shipmentDetail', 'N', 1);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'railDetail', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'truckDetail', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'airDetail', 'N', 4);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'landingDetail', 'N', 5);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'warehouseReceipt', 'N', 6);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'weightNote', 'N', 7);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'shipmentAdvise', 'N', 8);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'truckAdvice', 'N', 9);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'airAdvice', 'N', 10);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'railAdvice', 'N', 11);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'salesLandingDetail', 'N', 12);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'releaseOrder', 'N', 13);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'salesWeightNote', 'N', 14);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'shipmentBackToBack', 'N', 15);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'RECORD_OUT_PUT_TOLLING', 'N', 16);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'CREATE_FREE_MATERIAL', 'N', 17);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'MARK_FOR_TOLLING', 'N', 18);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'financialSettlement', 'N', 19);
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('IIOperationsActivity', 'pledgeTransfer', 'N', 20);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('invoicableItemSearch', 'contractRefNo', 'N', 1);
 
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
IS_INV_DRAFT,
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
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUALITY,
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
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
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
and PCM.CP_ID = PHD.PROFILEID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and PHD.PROFILEID = PAD.PROFILE_ID
and PAD.COUNTRY_ID = CYM.COUNTRY_ID
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.CONSIGNEE_ID = PHD1.PROFILEID(+)
and SD.CONSIGNEE_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED = ''N''
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
GMR.GMR_REF_NO,
GMR.QTY,
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
INVS.IS_INV_DRAFT';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID='DGM-DFT-FI' and DOC_ID='CREATE-DFT_FI';
  
end;

declare
fetchqry2 clob := 'INSERT INTO IS_D(
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
IS_INV_DRAFT,
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
II.STOCK_REF_NO as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUALITY,
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
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
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
and PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID(+)
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and PCM.CP_ID = PHD.PROFILEID(+)
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID(+)
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.CONSIGNEE_ID = PHD1.PROFILEID(+)
and SD.CONSIGNEE_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
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
II.STOCK_REF_NO,
CM.CUR_CODE,
GMR.GMR_REF_NO,
GMR.QTY,
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
INVS.IS_INV_DRAFT';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry2 where DGM_ID='DGM-DFT-FIC' and DOC_ID='CREATE_DFT_FI';
  
end;

declare
fetchqry3 clob := 'INSERT INTO IS_D(
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
IS_INV_DRAFT,
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
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUALITY,
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
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
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
and PCM.CP_ID = PHD.PROFILEID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and PHD.PROFILEID = PAD.PROFILE_ID
and PAD.COUNTRY_ID = CYM.COUNTRY_ID
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.CONSIGNEE_ID = PHD1.PROFILEID(+)
and SD.CONSIGNEE_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED = ''N''
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
GMR.GMR_REF_NO,
GMR.QTY,
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
INVS.IS_INV_DRAFT';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry3 where DGM_ID='DGM-DFT-DC' and DOC_ID='CREATE_DFT_DC';
  
end;

declare
fetchqry4 clob := 'INSERT INTO IS_D(
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
IS_INV_DRAFT,
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
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUALITY,
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
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
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
and PCM.CP_ID = PHD.PROFILEID
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID
and PHD.PROFILEID = PAD.PROFILE_ID
and PAD.COUNTRY_ID = CYM.COUNTRY_ID
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.CONSIGNEE_ID = PHD1.PROFILEID(+)
and SD.CONSIGNEE_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
and PAD.IS_DELETED = ''N''
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
GMR.GMR_REF_NO,
GMR.QTY,
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
INVS.IS_INV_DRAFT';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry4 where DGM_ID='DGM-DFT-PI' and DOC_ID='CREATE_DFT_PI';
  
end;

declare
fetchqry5 clob := 'INSERT INTO IS_D(
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
IS_INV_DRAFT,
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
II.STOCK_REF_NO as STOCK_REF_NO,
CM.CUR_CODE as INVOICE_AMOUNT_UNIT,
GMR.GMR_REF_NO as GMR_REF_NO,
GMR.QTY as GMR_QUALITY,
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
INVS.IS_INV_DRAFT as IS_INV_DRAFT,
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
and PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID(+)
and PCPD.PRODUCT_ID = PDM.PRODUCT_ID(+)
and PCM.CP_ID = PHD.PROFILEID(+)
and PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID(+)
and PHD.PROFILEID = PAD.PROFILE_ID(+)
and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
and PAD.CITY_ID = CIM.CITY_ID(+)
and PAD.STATE_ID = SM.STATE_ID(+)
and PAD.ADDRESS_TYPE = BPAT.BP_ADDRESS_TYPE_ID(+)
and CYMLOADING.COUNTRY_ID(+) = GMR.LOADING_COUNTRY_ID
and GMR.INTERNAL_GMR_REF_NO = SAD.INTERNAL_GMR_REF_NO(+)
and GMR.INTERNAL_GMR_REF_NO = SD.INTERNAL_GMR_REF_NO(+)
and SAD.CONSIGNEE_ID = PHD1.PROFILEID(+)
and SD.CONSIGNEE_ID = PHD2.PROFILEID(+)
and GMR.QTY_UNIT_ID = QUM_GMR.QTY_UNIT_ID(+)
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
II.STOCK_REF_NO,
CM.CUR_CODE,
GMR.GMR_REF_NO,
GMR.QTY,
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
INVS.IS_INV_DRAFT';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry5 where DGM_ID='DGM-DFT-PIC' and DOC_ID='CREATE_DFT_PI';
  
end;
CREATE OR REPLACE VIEW V_SMELTERS_IN_PROCESS AS
select debt_temp.corporate_id,
       debt_temp.smelter_id smelter_id,
       phd.companyname smelter_name,
       debt_temp.product_id product_id,
       debt_temp.product_name product_name,
       sum(debt_temp.total_qty) total_qty,
       debt_temp.qty_unit_id qty_unit_id,
       qum.qty_unit qty_unit
  from (select returnable_temp.corporate_id,
               returnable_temp.smelter_id smelter_id,
               returnable_temp.product_id,
               returnable_temp.product_name,
               sum(returnable_temp.total_qty) total_qty,
               returnable_temp.qty_unit_id,
               returnable_temp.qty_type
          from (select prrqs.corporate_id,
                       prrqs.cp_id smelter_id,
                       prrqs.product_id product_id,
                       pdm.product_desc product_name,
                       -1 *
                       sum(prrqs.qty_sign *
                           pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                prrqs.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                prrqs.qty)) total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       prrqs.qty_type qty_type
                  from prrqs_prr_qty_status       prrqs,
                       pdm_productmaster          pdm,
                       cpm_corporateproductmaster cpm
                 where prrqs.cp_type = 'Smelter'
                   and prrqs.is_active = 'Y'
                   and prrqs.qty_type = 'Returnable'
                   and prrqs.activity_action_id = 'financialSettlement'
                   and pdm.product_id = prrqs.product_id
                   and cpm.is_active = 'Y'
                   and cpm.is_deleted = 'N'
                   and cpm.product_id = pdm.product_id
                   and cpm.corporate_id = prrqs.corporate_id
                 group by prrqs.corporate_id,
                          prrqs.cp_id,
                          prrqs.product_id,
                          pdm.product_desc,
                          cpm.inventory_qty_unit,
                          prrqs.qty_type
                union all
                select spq.corporate_id,
                       spq.smelter_id,
                       bvc_product.base_product_id product_id,
                       bvc_product.base_product_name product_name,
                       sum(pkg_general.f_get_converted_quantity(cpm.product_id,
                                                                spq.qty_unit_id,
                                                                cpm.inventory_qty_unit,
                                                                (spq.payable_qty +
                                                                nvl(spq.free_metal_qty,
                                                                     0)))) total_qty,
                       cpm.inventory_qty_unit qty_unit_id,
                       spq.qty_type qty_type
                  from spq_stock_payable_qty       spq,
                       v_list_base_vs_conc_product bvc_product,
                       cpm_corporateproductmaster  cpm,
                       grd_goods_record_detail     grd
                 where spq.supplier_id is null
                   and spq.is_active = 'Y'
                   and spq.is_stock_split = 'N'
                   and spq.qty_type = 'Returnable'
                   and grd.internal_grd_ref_no = spq.internal_grd_ref_no
                   and bvc_product.element_id = spq.element_id
                   and bvc_product.product_id = grd.product_id
                   and bvc_product.quality_id = grd.quality_id
                   and cpm.is_active = 'Y'
                   and cpm.is_deleted = 'N'
                   and cpm.product_id = bvc_product.base_product_id
                   and cpm.corporate_id = spq.corporate_id
                 group by spq.corporate_id,
                          spq.smelter_id,
                          bvc_product.base_product_id,
                          bvc_product.base_product_name,
                          cpm.inventory_qty_unit,
                          spq.qty_type
                
                /* UNION all
                --Smelter Base Stock as Returnable(Debt)
                SELECT sbs.corporate_id,
                sbs.smelter_cp_id smelter_id,
                sbs.product_id product_id,
                pdm.product_desc product_name,
                SUM(pkg_general.f_get_converted_quantity(cpm.product_id,
                sbs.qty_unit_id,
                cpm.inventory_qty_unit,
                sbs.qty)) total_qty,
                cpm.inventory_qty_unit qty_unit_id,
                'Returnable' qty_type
                FROM   sbs_smelter_base_stock     sbs,
                pdm_productmaster          pdm,
                cpm_corporateproductmaster cpm
                WHERE  pdm.product_id = sbs.product_id
                AND    sbs.is_active = 'Y'
                AND    cpm.corporate_id = sbs.corporate_id
                AND    cpm.product_id = pdm.product_id
                AND    cpm.is_active = 'Y'
                AND    cpm.is_deleted = 'N'
                GROUP  BY sbs.corporate_id,
                sbs.smelter_cp_id,
                sbs.product_id,
                pdm.product_desc,
                cpm.inventory_qty_unit*/
                ) returnable_temp
         group by returnable_temp.corporate_id,
                  returnable_temp.smelter_id,
                  returnable_temp.product_id,
                  returnable_temp.product_name,
                  returnable_temp.qty_unit_id,
                  returnable_temp.qty_type
        union all
        select prrqs.corporate_id,
               prrqs.cp_id smelter_id,
               prrqs.product_id product_id,
               pdm.product_desc product_name,
               -1 *
               sum(prrqs.qty_sign *
                   pkg_general.f_get_converted_quantity(cpm.product_id,
                                                        prrqs.qty_unit_id,
                                                        cpm.inventory_qty_unit,
                                                        prrqs.qty)) total_qty,
               cpm.inventory_qty_unit qty_unit_id,
               prrqs.qty_type qty_type
          from prrqs_prr_qty_status       prrqs,
               pdm_productmaster          pdm,
               cpm_corporateproductmaster cpm
         where prrqs.cp_type = 'Smelter'
           and prrqs.is_active = 'Y'
           and prrqs.qty_type = 'Returned'
           and pdm.product_id = prrqs.product_id
           and cpm.is_active = 'Y'
           and cpm.is_deleted = 'N'
           and cpm.product_id = pdm.product_id
           and cpm.corporate_id = prrqs.corporate_id
         group by prrqs.corporate_id,
                  prrqs.cp_id,
                  prrqs.product_id,
                  pdm.product_desc,
                  cpm.inventory_qty_unit,
                  prrqs.qty_type) debt_temp,
       phd_profileheaderdetails phd,
       qum_quantity_unit_master qum
 where debt_temp.smelter_id = phd.profileid
   and debt_temp.qty_unit_id = qum.qty_unit_id
 group by debt_temp.corporate_id,
          debt_temp.smelter_id,
          phd.companyname,
          debt_temp.product_id,
          debt_temp.product_name,
          debt_temp.qty_unit_id,
          qum.qty_unit;
/
DECLARE
count1 Number(10);
BEGIN

   count1 := 1;   
   delete from CDC_CORPORATE_DOC_CONFIG where doc_id IN ('CREATE_SI','CREATE_DC'); 
   delete from DRF_DOC_REF_NUMBER_FORMAT where DOC_KEY_ID IN ('SI_KEY_2','SI_KEY_1','DC_KEY_1','DC_KEY_2');
   delete from DRFM_DOC_REF_NO_MAPPING where doc_id IN ('CREATE_SI','CREATE_DC');
   
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
   /* Corporate Script for Service Invoice */
      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id, doc_id, doc_template_name,
                   doc_template_name_de, doc_template_name_es,
                   doc_print_name, doc_print_name_de, doc_print_name_es,
                   doc_rpt_file_name, is_active, doc_auto_generate
                  )
           VALUES ('CDC-SI-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_SI', 'Service',
                   NULL, NULL,
                   NULL, NULL, NULL,
                   'ServiceInvoice.rpt', 'Y', 'Y'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id, corporate_id,
                   prefix, middle_no_start_value, middle_no_last_used_value,
                   suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-SI-'||TO_CHAR(count1), 'SI_KEY_2', cc.corporate_id,
                   'SI-', 0, 0,
                   '-' || cc.corporate_id, 1, 'N'
                  );

      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id, doc_id, doc_key_id,
                   is_deleted
                  )
           VALUES ('DRFM-SI-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_SI', 'SI_KEY_2',
                   'N'
                  );
    /* Corporate Script for Debit Credit Note */
      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id, doc_id, doc_key_id,
                   is_deleted
                  )
           VALUES ('DRFM-DC-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_DC', 'DC_KEY_2',
                   'N'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id, corporate_id,
                   prefix, middle_no_start_value, middle_no_last_used_value,
                   suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-DC-'||TO_CHAR(count1), 'DC_KEY_2', cc.corporate_id,
                   'DC-', 0, 0,
                   '-' || cc.corporate_id, 1, 'N'
                  );

      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id, doc_id, doc_template_name,
                   doc_template_name_de, doc_template_name_es,
                   doc_print_name, doc_print_name_de, doc_print_name_es,
                   doc_rpt_file_name, is_active, doc_auto_generate
                  )
           VALUES ('CDC-DC-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_DC', 'DebitCredit',
                   NULL, NULL,
                   NULL, NULL, NULL,
                   'PurchaseDebitCreditNote.rpt', 'Y', 'Y'
                  );
                  
      count1 := count1 + 1;
       
   END LOOP;
   COMMIT;
END;
delete from rpc_rf_parameter_config rpc where rpc.report_id = 235;
delete from rfc_report_filter_config rfc where rfc.report_id = 235;
commit;
SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
loop
    dbms_output.put_line(cc.corporate_id);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '235', 'RFC235PHY01', 1, 1, 
    'QP Start Date', 'GFF021', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '235', 'RFC235PHY02', 1, 2, 
    'QP End Date', 'GFF021', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '235', 'RFC235PHY03', 1, 3, 
    'Counter Party', 'GFF1001', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '235', 'RFC235PHY06', 1, 4, 
    'Product', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '235', 'RFC235PHY04', 1, 5, 
    'Quality', 'GFF1011', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '235', 'RFC235PHY05', 1, 6, 
    'Shipping Status', 'GFF1012', 1, 'N');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '235', 'RFC235PHY07', 1, 7, 
    'GMR Ref No', 'GFF10206', 1, 'N');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY07', 'RFP100533', 'GMRRefNo');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY01', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY01', 'RFP0026', 'QPStartDate');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY02', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY02', 'RFP0026', 'QPEndDate');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY03', 'RFP1001', 'businesspartner');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY03', 'RFP1002', 'CounterParty');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY03', 'RFP1003', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY03', 'RFP1004', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY03', 'RFP1005', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY03', 'RFP1006', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY03', 'RFP1008', 'BUYER,SELLER');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY04', 'RFP1045', 'quality');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY04', 'RFP1046', 'Quality');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY04', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY04', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY04', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY04', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY05', 'RFP1060', 'GMRListingStatus');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY05', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY05', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY05', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY05', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY05', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY05', 'RFP1061', 'ShippingStatus');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY06', 'RFP1045', 'allProducts');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY06', 'RFP1046', 'Product');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY06', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY06', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY06', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '235', 'RFC235PHY06', 'RFP1050', '1');
COMMIT;
  end loop;
commit;
end;
DECLARE
count1 Number(10);
BEGIN

   count1 := 1;   
   delete from CDC_CORPORATE_DOC_CONFIG where doc_id IN ('CREATE_SI','CREATE_DC'); 
   delete from DRF_DOC_REF_NUMBER_FORMAT where DOC_KEY_ID IN ('SI_KEY_2','SI_KEY_1','DC_KEY_1','DC_KEY_2');
   delete from DRFM_DOC_REF_NO_MAPPING where doc_id IN ('CREATE_SI','CREATE_DC');
   
   FOR cc IN (SELECT akc.corporate_id
                FROM ak_corporate akc
               WHERE akc.is_active = 'Y' AND akc.is_internal_corporate = 'N')
   LOOP
   /* Corporate Script for Service Invoice */
      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id, doc_id, doc_template_name,
                   doc_template_name_de, doc_template_name_es,
                   doc_print_name, doc_print_name_de, doc_print_name_es,
                   doc_rpt_file_name, is_active, doc_auto_generate
                  )
           VALUES ('CDC-SI-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_SI', 'Service',
                   NULL, NULL,
                   NULL, NULL, NULL,
                   'ServiceInvoice.rpt', 'Y', 'Y'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id, corporate_id,
                   prefix, middle_no_start_value, middle_no_last_used_value,
                   suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-SI-'||TO_CHAR(count1), 'SI_KEY_2', cc.corporate_id,
                   'SI-', 0, 0,
                   '-' || cc.corporate_id, 1, 'N'
                  );

      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id, doc_id, doc_key_id,
                   is_deleted
                  )
           VALUES ('DRFM-SI-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_SI', 'SI_KEY_2',
                   'N'
                  );
    /* Corporate Script for Debit Credit Note */
      INSERT INTO drfm_doc_ref_no_mapping
                  (doc_ref_no_mapping_id, corporate_id, doc_id, doc_key_id,
                   is_deleted
                  )
           VALUES ('DRFM-DC-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_DC', 'DC_KEY_2',
                   'N'
                  );

      INSERT INTO drf_doc_ref_number_format
                  (doc_ref_number_format_id, doc_key_id, corporate_id,
                   prefix, middle_no_start_value, middle_no_last_used_value,
                   suffix, VERSION, is_deleted
                  )
           VALUES ('DRF-DC-'||TO_CHAR(count1), 'DC_KEY_2', cc.corporate_id,
                   'DC-', 0, 0,
                   '-' || cc.corporate_id, 1, 'N'
                  );

      INSERT INTO cdc_corporate_doc_config
                  (doc_template_id, corporate_id, doc_id, doc_template_name,
                   doc_template_name_de, doc_template_name_es,
                   doc_print_name, doc_print_name_de, doc_print_name_es,
                   doc_rpt_file_name, is_active, doc_auto_generate
                  )
           VALUES ('CDC-DC-'||TO_CHAR(count1), cc.corporate_id, 'CREATE_DC', 'DebitCredit',
                   NULL, NULL,
                   NULL, NULL, NULL,
                   'PurchaseDebitCreditNote.rpt', 'Y', 'Y'
                  );
                  
      count1 := count1 + 1;
       
   END LOOP;
   COMMIT;
END;

SET DEFINE OFF;

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('positionAssay', 'Position Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('wtAvgPositionAssay', 'Weighted Avg Position Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('pricingAssay', 'Pricing Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('wtAvgPricingAssay', 'Weighted Avg Pricing Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('invoicingAssay', 'Invoicing Assay');
   
   Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('wtAvgInvoicingAssay','Weighted Avg Invoice Assay');

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'Self', 'N', 1);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'Counterparty', 'N', 2);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'Umpire', 'N', 3);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'Final', 'N', 4);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'ProvisionalAssay', 'N', 5);

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'WSAssay', 'N', 6);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'positionAssay', 'N', 7);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'wtAvgPositionAssay', 'N', 8);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'pricingAssay', 'N', 9);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'wtAvgPricingAssay', 'N', 10);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'invoicingAssay', 'N', 11);
   
   Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('assayTypeSearchCriteriaList', 'wtAvgInvoicingAssay', 'N', 12);

   alter table AS_ASSAY_D add(WEIGHING_SAMPLING_DATE date);
   declare
fetchqry1 clob := 'INSERT INTO AS_ASSAY_D(
INTERNAL_CONTRACT_ITEM_REF_NO,
ASSAY_REFNO,
INTERNAL_GMR_REF_NO ,
CONTRACT_TYPE       ,
ACTIVITY_DATE      ,
ship_land_date ,
BUYER               ,
SELLER            ,
OUR_CONTRACT_REF_NO ,
CP_CONTRACT_REF_NO ,
GMR_REF_NO         ,
SHIPMENT_DATE      ,
WEIGHING_AND_SAMPLING_REF_NO  ,
WEIGHING_SAMPLING_DATE,
PRODUCT_AND_QUALITY ,
ASSAYER      ,
ASSAY_TYPE     ,
EXCHANGE_OF_ASSAYS ,
LOT_NO      ,
NO_OF_SUBLOTS,
CONSOLIDATED_GROUP_ID,
INTERNAL_DOC_REF_NO 
)
SELECT VPCI.INTERNAL_CONTRACT_ITEM_REF_NO AS INTERNAL_CONTRACT_ITEM_REF_NO,
       ASH.ASSAY_REF_NO AS ASSAY_REFNO,
       ASH.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
       GMR.CONTRACT_TYPE AS CONTRACT_TYPE,AXS.EFF_DATE AS ACTIVITY_DATE,
       (CASE
           WHEN ash.assay_type = ''Provisional Assay''
              THEN (SELECT vd.loading_date
                      FROM vd_voyage_detail vd
                     WHERE vd.internal_gmr_ref_no = gmr.internal_gmr_ref_no)
           ELSE (CASE
                    WHEN (SELECT agmr.action_no AS actionno
                            FROM agmr_action_gmr agmr
                           WHERE agmr.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no
                             AND agmr.is_deleted = ''N''
                             AND agmr.is_final_weight = ''Y'') = 1
                       THEN (SELECT vd.loading_date
                               FROM vd_voyage_detail vd
                              WHERE vd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                    ELSE (SELECT wrd.storage_date
                            FROM wrd_warehouse_receipt_detail wrd
                           WHERE wrd.internal_gmr_ref_no =
                                                       gmr.internal_gmr_ref_no)
                 END
                )
        END
       ) ship_land_date,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Sales''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) BUYER,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Purchase''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) SELLER,
       VPCI.CONTRACT_REF_NO AS OUR_CONTRACT_REF_NO,
       VPCI.CP_CONTRACT_REF_NO AS CP_CONTRACT_REF_NO,
       GMR.GMR_REF_NO AS GMR_REF_NO, GMR.EFF_DATE AS SHIPMENT_DATE,
       (SELECT ASH1.ASSAY_REF_NO
          FROM ASH_ASSAY_HEADER ASH1
         WHERE ASH1.ASSAY_TYPE =
                   ''Weighing and Sampling Assay''
           AND ASH1.IS_ACTIVE = ''Y''
           AND nvl(ASH1.IS_DELETE,''N'') = ''N'' 
           AND ASH1.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
           AND ASH1.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
           AND ASH1.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)
                                                 WEIGHING_AND_SAMPLING_REF_NO,
          (SELECT ASH1.ACTIVITY_DATE
          FROM ASH_ASSAY_HEADER ASH1
         WHERE ASH1.ASSAY_TYPE =
                   ''Weighing and Sampling Assay''
           AND ASH1.IS_ACTIVE = ''Y''
           AND nvl(ASH1.IS_DELETE,''N'') = ''N'' 
           AND ASH1.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
           AND ASH1.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
           AND ASH1.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)
                                                 WEIGHING_SAMPLING_DATE,                                      
        (VPCI.PRODUCT_NAME
           || '' , ''
           || VPCI.QUALITY_NAME
       ) PRODUCT_AND_QUALITY,
       BGM.BP_GROUP_NAME as ASSAYER,
       ASH.ASSAY_TYPE AS ASSAY_TYPE,
       ASH.USE_FOR_FINALIZATION AS EXCHANGE_OF_ASSAYS, ASH.LOT_NO AS LOT_NO,
       ASH.NO_OF_SUBLOTS AS NO_OF_SUBLOTS,ASH.CONSOLIDATED_GROUP_ID AS CONSOLIDATED_GROUP_ID,?
  FROM ASH_ASSAY_HEADER ASH,
       AXS_ACTION_SUMMARY AXS,
       V_PCI VPCI,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       BGM_BP_GROUP_MASTER bgm
 WHERE ASH.INTERNAL_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
   AND ASH.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND GMR.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND ASH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND BGM.BP_GROUP_ID(+) = ASH.ASSAYER
  AND ASH.ASH_ID = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1  where DGM_ID='DGM-AS' and ACTIVITY_ID='CREATE_ASSAY';
  
end;

declare
fetchqry2 clob := 'INSERT INTO WNS_ASSAY_D(
INTERNAL_CONTRACT_ITEM_REF_NO,
INTERNAL_GMR_REF_NO ,
CONTRACT_TYPE       ,
ACTIVITY_REFNO     ,
ACTIVITY_DATE      ,
BUYER               ,
SELLER            ,
OUR_CONTRACT_REF_NO ,
CP_CONTRACT_REF_NO ,
GMR_REF_NO         ,
SHIPMENT_DATE      ,
WEIGHER_AND_SAMPLER  ,
PRODUCT_AND_QUALITY ,
WEIGHING_SAMPLING_DATE ,
LOT_NO      ,
NO_OF_SUBLOTS,
WNS_GROUP_ID,
IS_SUBLOTS_AS_STOCK,
ARRIVAL_DATE,
INTERNAL_DOC_REF_NO
)
SELECT VPCI.INTERNAL_CONTRACT_ITEM_REF_NO AS INTERNAL_CONTRACT_ITEM_REF_NO,
       ASH.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
       GMR.CONTRACT_TYPE AS CONTRACT_TYPE,
       ASH.ASSAY_REF_NO AS ACTIVITY_REFNO, AXS.EFF_DATE AS ACTIVITY_DATE,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Sales''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) BUYER,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Purchase''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) SELLER,
       VPCI.CONTRACT_REF_NO AS OUR_CONTRACT_REF_NO,
       VPCI.CP_CONTRACT_REF_NO AS CP_CONTRACT_REF_NO,
       GMR.GMR_REF_NO AS GMR_REF_NO, GMR.EFF_DATE AS SHIPMENT_DATE,
       BGM.BP_GROUP_NAME AS WEIGHER_AND_SAMPLER,
        (VPCI.PRODUCT_NAME
           || '' , ''
           || VPCI.QUALITY_NAME
       ) PRODUCT_AND_QUALITY,
       ASH.SAMPLE_DATE AS WEIGHING_SAMPLING_DATE, ASH.LOT_NO AS LOT_NO,
       ASH.NO_OF_SUBLOTS AS NO_OF_SUBLOTS,
       ASH.WNS_GROUP_ID AS WNS_GROUP_ID,
       ASH.IS_SUBLOTS_AS_STOCK AS IS_SUBLOTS_AS_STOCK,
       GMR.ARRIVAL_DATE AS ARRIVAL_DATE,?
  FROM ASH_ASSAY_HEADER ASH,
       AXS_ACTION_SUMMARY AXS,
       V_PCI VPCI,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       GRD_GOODS_RECORD_DETAIL grd,
       BGM_BP_GROUP_MASTER BGM
 WHERE ASH.INTERNAL_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
   AND ASH.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND GMR.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND ASH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND BGM.BP_GROUP_ID(+) = ASH.ASSAYER
   and GRD.INTERNAL_CONTRACT_ITEM_REF_NO=VPCI.INTERNAL_CONTRACT_ITEM_REF_NO
   and ASH.INTERNAL_GRD_REF_NO=GRD.INTERNAL_GRD_REF_NO
   AND ASH.ASH_ID = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry2 where DGM_ID='DGM-WNS' and ACTIVITY_ID='CREATE_WNS_ASSAY';
  
end;


Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('TCLOST', 'List Of Standard Text', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},
{"dataIndex":"documentType","header":"Document Name","id":1,"sortable":true,"width":100},
{"dataIndex":"txtShortName","header":"Text Name","id":2,"sortable":true,"width":120},
{"dataIndex":"txtDescription","header":"Content","id":3,"sortable":true,"width":250}]', NULL, NULL, 
    '[
                        {name: ''txtId'', mapping: ''txtId''},
                        {name: ''documentType'', mapping: ''documentType''},
                        {name: ''txtShortName'', mapping: ''txtShortName''},    
                        {name: ''txtDescription'', mapping: ''txtDescription''}
                    ]', '/private/jsp/physical/termsnconditions/termsnconditionspopup.jsp', '/private/jsp/physical/termsnconditions/tncstandardtextlist.jsp', '/private/js/physical/termsconditions/tncstandardtextlist.js');



create or replace trigger "TRG_INSERT_DT_QTY_LOG"
/**************************************************************************************************
           Trigger Name                       : TRG_INSERT_DT_QTY_LOG
           Author                             : Venu
           Created Date                       : 17th May 2012
           Purpose                            : To Insert into DT_QTY_LOG Table

           Modification History

           Modified Date  :
           Modified By  :
           Modify Description :

   ***************************************************************************************************/
  after insert or update or delete on dt_derivative_trade
  for each row
declare
  v_total_qty      number(25, 4);
  v_open_qty       number(25, 4);
  v_closed_qty     number(25, 4);
  v_exercised_qty  number(25, 4);
  v_expired_qty    number(25, 4);
  v_total_lots     number(5);
  v_open_lots      number(5);
  v_closed_lots    number(5);
  v_exercised_lots number(5);
  v_expired_lots   number(5);
begin
  --
  -- If updating then put the delta for Quantity columns as Old - New
  -- If inserting put the new value as is as Delta
  --
  if updating then
    --Qty Unit is Not Updated
    if (:new.quantity_unit_id = :old.quantity_unit_id) then
    
      v_total_qty      := nvl(:new.total_quantity, 0) -
                          nvl(:old.total_quantity, 0);
      v_open_qty       := nvl(:new.open_quantity, 0) -
                          nvl(:old.open_quantity, 0);
      v_closed_qty     := nvl(:new.closed_quantity, 0) -
                          nvl(:old.closed_quantity, 0);
      v_exercised_qty  := nvl(:new.exercised_quantity, 0) -
                          nvl(:old.exercised_quantity, 0);
      v_expired_qty    := nvl(:new.expired_quantity, 0) -
                          nvl(:old.expired_quantity, 0);
      v_total_lots     := nvl(:new.total_lots, 0) - nvl(:old.total_lots, 0);
      v_open_lots      := nvl(:new.open_lots, 0) - nvl(:old.open_lots, 0);
      v_closed_lots    := nvl(:new.closed_lots, 0) -
                          nvl(:old.closed_lots, 0);
      v_exercised_lots := nvl(:new.exercised_lots, 0) -
                          nvl(:old.exercised_lots, 0);
      v_expired_lots   := nvl(:new.expired_lots, 0) -
                          nvl(:old.expired_lots, 0);
    
      if nvl(:new.status, 'XXX') = 'Delete' then
        v_total_qty := 0 - nvl(:old.total_quantity, 0);
      end if;
    
      if v_total_qty <> 0 or v_open_qty <> 0 or v_closed_qty <> 0 or
         v_exercised_qty <> 0 or v_expired_qty <> 0 or v_total_lots <> 0 or
         v_open_lots <> 0 or v_closed_lots <> 0 or v_exercised_lots <> 0 or
         v_expired_lots <> 0 then
        insert into dt_qty_log
          (internal_derivative_ref_no,
           derivative_ref_no,
           internal_action_ref_no,
           dr_id,
           corporate_id,
           status,
           quantity_unit_id,
           total_quantity_delta,
           open_quantity_delta,
           closed_quantity_delta,
           exercised_quantity_delta,
           expired_quantity_delta,
           total_lots_delta,
           open_lots_delta,
           closed_lots_delta,
           exercised_lots_delta,
           expired_lots_delta,
           entry_type)
        values
          (:new.internal_derivative_ref_no,
           :new.derivative_ref_no,
           :new.latest_internal_action_ref_no,
           :new.dr_id,
           :new.corporate_id,
           :new.status,
           :new.quantity_unit_id,
           v_total_qty,
           v_open_qty,
           v_closed_qty,
           v_exercised_qty,
           v_expired_qty,
           v_total_lots,
           v_open_lots,
           v_closed_lots,
           v_exercised_lots,
           v_expired_lots,
           'Update');
      end if;
    elsif deleting then
      insert into dt_qty_log
        (internal_derivative_ref_no,
         derivative_ref_no,
         internal_action_ref_no,
         dr_id,
         corporate_id,
         status,
         quantity_unit_id,
         total_quantity_delta,
         open_quantity_delta,
         closed_quantity_delta,
         exercised_quantity_delta,
         expired_quantity_delta,
         total_lots_delta,
         open_lots_delta,
         closed_lots_delta,
         exercised_lots_delta,
         expired_lots_delta,
         entry_type)
      values
        (:new.internal_derivative_ref_no,
         :new.derivative_ref_no,
         :new.latest_internal_action_ref_no,
         :new.dr_id,
         :new.corporate_id,
         :new.status,
         :new.quantity_unit_id,
         :new.total_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.total_quantity),
         :new.open_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.open_quantity),
         :new.closed_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.closed_quantity),
         :new.exercised_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.exercised_quantity),
         :new.expired_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.expired_quantity),
         :new.total_lots - :old.total_lots,
         :new.open_lots - :old.open_lots,
         :new.closed_lots - :old.closed_lots,
         :new.exercised_lots - :old.exercised_lots,
         :new.expired_lots - :old.expired_lots,
         'Delete');
    else
      --Qty Unit is Updated
      insert into dt_qty_log
        (internal_derivative_ref_no,
         derivative_ref_no,
         internal_action_ref_no,
         dr_id,
         corporate_id,
         status,
         quantity_unit_id,
         total_quantity_delta,
         open_quantity_delta,
         closed_quantity_delta,
         exercised_quantity_delta,
         expired_quantity_delta,
         total_lots_delta,
         open_lots_delta,
         closed_lots_delta,
         exercised_lots_delta,
         expired_lots_delta,
         entry_type)
      values
        (:new.internal_derivative_ref_no,
         :new.derivative_ref_no,
         :new.latest_internal_action_ref_no,
         :new.dr_id,
         :new.corporate_id,
         :new.status,
         :new.quantity_unit_id,
         :new.total_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.total_quantity),
         :new.open_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.open_quantity),
         :new.closed_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.closed_quantity),
         :new.exercised_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.exercised_quantity),
         :new.expired_quantity -
         pkg_general.f_get_converted_quantity(null,
                                              :old.quantity_unit_id,
                                              :new.quantity_unit_id,
                                              :old.expired_quantity),
         :new.total_lots - :old.total_lots,
         :new.open_lots - :old.open_lots,
         :new.closed_lots - :old.closed_lots,
         :new.exercised_lots - :old.exercised_lots,
         :new.expired_lots - :old.expired_lots,
         'Update');
    
    end if;
  
  else
    --
    -- New Entry ( Entry Type=Insert)
    --
    insert into dt_qty_log
      (internal_derivative_ref_no,
       derivative_ref_no,
       internal_action_ref_no,
       dr_id,
       corporate_id,
       status,
       quantity_unit_id,
       total_quantity_delta,
       open_quantity_delta,
       closed_quantity_delta,
       exercised_quantity_delta,
       expired_quantity_delta,
       total_lots_delta,
       open_lots_delta,
       closed_lots_delta,
       exercised_lots_delta,
       expired_lots_delta,
       entry_type)
    values
      (:new.internal_derivative_ref_no,
       :new.derivative_ref_no,
       :new.latest_internal_action_ref_no,
       :new.dr_id,
       :new.corporate_id,
       :new.status,
       :new.quantity_unit_id,
       :new.total_quantity,
       :new.open_quantity,
       :new.closed_quantity,
       :new.exercised_quantity,
       :new.expired_quantity,
       :new.total_lots,
       :new.open_lots,
       :new.closed_lots,
       :new.exercised_lots,
       :new.expired_lots,
       'Insert');
  
  end if;
end;
/

INSERT INTO slv_static_list_value
            (value_id, value_text
            )
     VALUES ('ContractItemRefNo', 'Contract Item Ref No.'
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('GMRSearchCriteria', 'GMR Ref No', 'N', 1
            );
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('GMRSearchCriteria', 'Contract Ref No', 'N', 2
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('GMRSearchCriteria', 'ContractItemRefNo', 'N', 3
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('GMRSearchCriteria', 'Container No', 'N', 4
            );
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('GMRSearchCriteria', 'B/L No', 'N', 5
            );
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('GMRSearchCriteria', 'ActivityRefNo', 'N', 6
            );
INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('GMRSearchCriteria', 'VoyageNo', 'N', 7
            );

INSERT INTO sls_static_list_setup
            (list_type, value_id, is_default, display_order
            )
     VALUES ('GMRSearchCriteria', 'StockRefNo', 'N', 8
            );
declare
fetchqry1 clob := 'INSERT INTO AS_ASSAY_D(
INTERNAL_CONTRACT_ITEM_REF_NO,
ASSAY_REFNO,
INTERNAL_GMR_REF_NO ,
CONTRACT_TYPE       ,
ACTIVITY_DATE      ,
ship_land_date ,
BUYER               ,
SELLER            ,
OUR_CONTRACT_REF_NO ,
CP_CONTRACT_REF_NO ,
GMR_REF_NO         ,
SHIPMENT_DATE      ,
WEIGHING_AND_SAMPLING_REF_NO  ,
WEIGHING_SAMPLING_DATE,
PRODUCT_AND_QUALITY ,
ASSAYER      ,
ASSAY_TYPE     ,
EXCHANGE_OF_ASSAYS ,
LOT_NO      ,
NO_OF_SUBLOTS,
CONSOLIDATED_GROUP_ID,
INTERNAL_DOC_REF_NO 
)
SELECT VPCI.INTERNAL_CONTRACT_ITEM_REF_NO AS INTERNAL_CONTRACT_ITEM_REF_NO,
       ASH.ASSAY_REF_NO AS ASSAY_REFNO,
       ASH.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
       GMR.CONTRACT_TYPE AS CONTRACT_TYPE,AXS.EFF_DATE AS ACTIVITY_DATE,
       (SELECT agmr.eff_date AS ship_land_date
          FROM agmr_action_gmr agmr
         WHERE agmr.internal_gmr_ref_no =
                                       gmr.internal_gmr_ref_no
           AND agmr.is_deleted = ''N''
           AND agmr.action_no = ''1'') ship_land_date,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Sales''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) BUYER,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Purchase''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) SELLER,
       VPCI.CONTRACT_REF_NO AS OUR_CONTRACT_REF_NO,
       VPCI.CP_CONTRACT_REF_NO AS CP_CONTRACT_REF_NO,
       GMR.GMR_REF_NO AS GMR_REF_NO, GMR.EFF_DATE AS SHIPMENT_DATE,
       (SELECT ASH1.ASSAY_REF_NO
          FROM ASH_ASSAY_HEADER ASH1
         WHERE ASH1.ASSAY_TYPE =
                   ''Weighing and Sampling Assay''
           AND ASH1.IS_ACTIVE = ''Y''
           AND nvl(ASH1.IS_DELETE,''N'') = ''N'' 
           AND ASH1.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
           AND ASH1.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
           AND ASH1.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)
                                                 WEIGHING_AND_SAMPLING_REF_NO,
          (SELECT ASH1.ACTIVITY_DATE
          FROM ASH_ASSAY_HEADER ASH1
         WHERE ASH1.ASSAY_TYPE =
                   ''Weighing and Sampling Assay''
           AND ASH1.IS_ACTIVE = ''Y''
           AND nvl(ASH1.IS_DELETE,''N'') = ''N'' 
           AND ASH1.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
           AND ASH1.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
           AND ASH1.INTERNAL_GRD_REF_NO = ASH.INTERNAL_GRD_REF_NO)
                                                 WEIGHING_SAMPLING_DATE,                                      
        (VPCI.PRODUCT_NAME
           || '' , ''
           || VPCI.QUALITY_NAME
       ) PRODUCT_AND_QUALITY,
       BGM.BP_GROUP_NAME as ASSAYER,
       ASH.ASSAY_TYPE AS ASSAY_TYPE,
       ASH.USE_FOR_FINALIZATION AS EXCHANGE_OF_ASSAYS, ASH.LOT_NO AS LOT_NO,
       ASH.NO_OF_SUBLOTS AS NO_OF_SUBLOTS,ASH.CONSOLIDATED_GROUP_ID AS CONSOLIDATED_GROUP_ID,?
  FROM ASH_ASSAY_HEADER ASH,
       AXS_ACTION_SUMMARY AXS,
       V_PCI VPCI,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       BGM_BP_GROUP_MASTER bgm
 WHERE ASH.INTERNAL_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
   AND ASH.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND GMR.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND ASH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND BGM.BP_GROUP_ID(+) = ASH.ASSAYER
  AND ASH.ASH_ID = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1  where DGM_ID='DGM-AS' and ACTIVITY_ID='CREATE_ASSAY';
  
end;

declare
fetchqry2 clob := 'INSERT INTO WNS_ASSAY_D(
INTERNAL_CONTRACT_ITEM_REF_NO,
INTERNAL_GMR_REF_NO ,
CONTRACT_TYPE       ,
ACTIVITY_REFNO     ,
ACTIVITY_DATE      ,
BUYER               ,
SELLER            ,
OUR_CONTRACT_REF_NO ,
CP_CONTRACT_REF_NO ,
GMR_REF_NO         ,
SHIPMENT_DATE      ,
WEIGHER_AND_SAMPLER  ,
PRODUCT_AND_QUALITY ,
WEIGHING_SAMPLING_DATE ,
LOT_NO      ,
NO_OF_SUBLOTS,
WNS_GROUP_ID,
IS_SUBLOTS_AS_STOCK,
ARRIVAL_DATE,
INTERNAL_DOC_REF_NO
)
SELECT VPCI.INTERNAL_CONTRACT_ITEM_REF_NO AS INTERNAL_CONTRACT_ITEM_REF_NO,
       ASH.INTERNAL_GMR_REF_NO AS INTERNAL_GMR_REF_NO,
       GMR.CONTRACT_TYPE AS CONTRACT_TYPE,
       ASH.ASSAY_REF_NO AS ACTIVITY_REFNO, AXS.EFF_DATE AS ACTIVITY_DATE,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Sales''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) BUYER,
       (CASE
           WHEN GMR.CONTRACT_TYPE = ''Purchase''
              THEN VPCI.CP_NAME
           ELSE VPCI.CORPORATE_NAME
        END
       ) SELLER,
       VPCI.CONTRACT_REF_NO AS OUR_CONTRACT_REF_NO,
       VPCI.CP_CONTRACT_REF_NO AS CP_CONTRACT_REF_NO,
       GMR.GMR_REF_NO AS GMR_REF_NO, GMR.EFF_DATE AS SHIPMENT_DATE,
       BGM.BP_GROUP_NAME AS WEIGHER_AND_SAMPLER,
        (VPCI.PRODUCT_NAME
           || '' , ''
           || VPCI.QUALITY_NAME
       ) PRODUCT_AND_QUALITY,
       ASH.SAMPLE_DATE AS WEIGHING_SAMPLING_DATE, ASH.LOT_NO AS LOT_NO,
       ASH.NO_OF_SUBLOTS AS NO_OF_SUBLOTS,
       ASH.WNS_GROUP_ID AS WNS_GROUP_ID,
       ASH.IS_SUBLOTS_AS_STOCK AS IS_SUBLOTS_AS_STOCK,
       (SELECT agmr.eff_date AS ship_land_date
          FROM agmr_action_gmr agmr
         WHERE agmr.internal_gmr_ref_no =
                                       gmr.internal_gmr_ref_no
           AND agmr.is_deleted = ''N''
           AND agmr.action_no = ''1'') ARRIVAL_DATE,?
  FROM ASH_ASSAY_HEADER ASH,
       AXS_ACTION_SUMMARY AXS,
       V_PCI VPCI,
       GMR_GOODS_MOVEMENT_RECORD GMR,
       GRD_GOODS_RECORD_DETAIL grd,
       BGM_BP_GROUP_MASTER BGM
 WHERE ASH.INTERNAL_ACTION_REF_NO = AXS.INTERNAL_ACTION_REF_NO
   AND ASH.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND GMR.INTERNAL_CONTRACT_REF_NO = VPCI.INTERNAL_CONTRACT_REF_NO
   AND ASH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
   AND BGM.BP_GROUP_ID(+) = ASH.ASSAYER
   and GRD.INTERNAL_CONTRACT_ITEM_REF_NO=VPCI.INTERNAL_CONTRACT_ITEM_REF_NO
   and ASH.INTERNAL_GRD_REF_NO=GRD.INTERNAL_GRD_REF_NO
   AND ASH.ASH_ID = ?';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry2 where DGM_ID='DGM-WNS' and ACTIVITY_ID='CREATE_WNS_ASSAY';
  
end;

UPDATE gmc_grid_menu_configuration gmc
   SET gmc.menu_display_name = 'Proforma Invoice'
 WHERE gmc.grid_id = 'MLOCI' AND gmc.menu_id = 'MLOCI_3_1';
 alter table TAD_TRADE_ALLOCATION_DETAILS add IS_FREE_METAL_PRICE_FIXATION char(1 ) default 'N';
alter table TAD_TRADE_ALLOCATION_DETAILS add FREE_METAL_PRICE_FIXATION_ID VARCHAR2(15 CHAR);

ALTER TABLE TAD_TRADE_ALLOCATION_DETAILS ADD (
  FOREIGN KEY (FREE_METAL_PRICE_FIXATION_ID) 
 REFERENCES FMPFD_PRICE_FIXATION_DETAILS (FMPFD_ID));

 -- Created on 7/31/2012
declare
  cursor gmr_product_cur is
    select distinct gmr_inner.internal_gmr_ref_no internal_gmr_ref_no,
                    grd.product_id                product_id
      from grd_goods_record_detail   grd,
           gmr_goods_movement_record gmr_inner
     where gmr_inner.internal_gmr_ref_no = grd.internal_gmr_ref_no
       and gmr_inner.is_deleted = 'N'
          
       and grd.status = 'Active'
       and nvl(gmr_inner.tolling_gmr_type, 'None Tolling') not in
           ('Input Process', 'Output Process', 'Mark For Tolling',
            'Received Materials', 'Pledge', 'Financial Settlement',
            'Return Material', 'Free Metal Utility')
    
    
     group by gmr_inner.internal_gmr_ref_no,
              grd.product_id
    union
    select distinct gmr_inner.internal_gmr_ref_no internal_gmr_ref_no,
                    dgrd.product_id               product_id
      from dgrd_delivered_grd        dgrd,
           gmr_goods_movement_record gmr_inner
     where gmr_inner.internal_gmr_ref_no = dgrd.internal_gmr_ref_no
       and gmr_inner.is_deleted = 'N'
          
       and dgrd.status = 'Active'
       and nvl(gmr_inner.tolling_gmr_type, 'None Tolling') not in
           ('Input Process', 'Output Process', 'Mark For Tolling',
            'Received Materials', 'Pledge', 'Financial Settlement',
            'Return Material', 'Free Metal Utility')
    
    
     group by gmr_inner.internal_gmr_ref_no,
              dgrd.product_id;

begin

  for gmr_product_cur_rows in gmr_product_cur
  loop
    
    update gmr_goods_movement_record gmr
       set gmr.product_id = gmr_product_cur_rows.product_id
     where gmr.internal_gmr_ref_no =
           gmr_product_cur_rows.internal_gmr_ref_no;
  end loop;
end;
/
create or replace view v_list_of_gmr_new as
select gmr.corporate_id,
       cp.contract_ref_no contract_ref_no,
       gmr.trucking_receipt_no trucking_receipt_no,
       gmr.rail_receipt_no rail_receipt_no,
       to_char(gmr.trucking_receipt_date, 'dd-Mon-yyyy') trucking_receipt_date,
       to_char(gmr.rail_receipt_date, 'dd-Mon-yyyy') rail_receipt_date,
       axs.action_id,
       gmr.internal_gmr_ref_no,
       gmr.gmr_ref_no,
       axs.internal_action_ref_no,
       axs.eff_date activity_date,
       axs.action_ref_no activity_ref_no,
       gmr.warehouse_receipt_no warehouse_receipt_no,
       gmr.warehouse_profile_id warehouse_profile_id,
       phd_warehouse.companyname warehouse,
       gmr.shed_id shed_id,
       sld.storage_location_name shed_name,
       gmr.product_id,
       pdm.product_desc product_name,
       nvl(nvl(gmr.current_qty, 0) - nvl(moved_out_qty, 0) -
           nvl(gmr.write_off_qty, 0),
           0) current_qty,
       gmr.qty_unit_id,
       qum.qty_unit,
       gmr.status_id,
       gsm.status status,
       gmr.inventory_status is_title_transfered,
       (select vcd.vessel_name
          from vcd_vessel_creation_detail vcd
         where vcd.vessel_id = vd.vessel_id) vessel_name,
       gmr.gmr_latest_action_action_id latest_action_id,
       (select axm.action_name
          from axm_action_master axm
         where axm.action_id = gmr.gmr_latest_action_action_id) latest_action_name,
       axm.action_name first_action_name,
       axs.action_ref_no,
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
       cp.contract_item_ref_no item_nos,
       nvl(gmr.tt_in_qty, 0) tt_in_qty,
       nvl(gmr.tt_out_qty, 0) tt_out_qty,
       nvl(gmr.tt_none_qty, 0) tt_none_qty,
       vd.vessel_voyage_name,
       vd.booking_ref_no,
       gmr.internal_contract_ref_no,
       sd.bl_no,
       sd.bl_date,
       gmr.created_date,
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
       gsm_gmr_stauts_master gsm,
       qum_quantity_unit_master qum,
       axm_action_master axm,
       phd_profileheaderdetails phd_warehouse,
       sld_storage_location_detail sld,
       vd_voyage_detail vd,
       (select gcim.internal_gmr_ref_no internal_gmr_ref_no,
               f_string_aggregate(pcm.contract_ref_no) contract_ref_no,
               f_string_aggregate(pcm.cp_id) contract_party_profile_id,
               f_string_aggregate(phd.companyname) as cp_name,
               f_string_aggregate(pcm.contract_ref_no || ' ' || 'Item No.' || ' ' ||
                                  pci.del_distribution_item_no) contract_item_ref_no,
               f_string_aggregate(pcdi.price_allocation_method) as price_allocation_method
          from pci_physical_contract_item     pci,
               pcm_physical_contract_main     pcm,
               pcdb_pc_delivery_basis         pcdb,
               pcdi_pc_delivery_item          pcdi,
               phd_profileheaderdetails       phd,
               gcim_gmr_contract_item_mapping gcim
         where pcdb.pcdb_id = pci.pcdb_id
           and pci.pcdi_id = pcdi.pcdi_id
           and phd.profileid = pcm.cp_id
           and pcm.internal_contract_ref_no = pcdb.internal_contract_ref_no
           and pci.is_active = 'Y'
           and pcm.contract_status = 'In Position'
           and (pci.is_called_off = 'Y' or
               pcdi.is_phy_optionality_present = 'N')
           and pci.internal_contract_item_ref_no =
               gcim.internal_contract_item_ref_no
         group by gcim.internal_gmr_ref_no) cp,
       sd_shipment_detail sd,
       pdm_productmaster pdm
 where gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no(+)
   and gam.internal_action_ref_no(+) = gmr.gmr_first_int_action_ref_no
   and axs.internal_action_ref_no(+) = gam.internal_action_ref_no
   and axs.status(+) = 'Active'
   and axm.action_id(+) = axs.action_id
   and gmr.is_deleted = 'N'
   and gmr.status_id = gsm.status_id
   and gmr.qty_unit_id = qum.qty_unit_id
   and gmr.warehouse_profile_id = phd_warehouse.profileid(+)
   and gmr.shed_id = sld.storage_loc_id(+)
   and gmr.internal_gmr_ref_no = cp.internal_gmr_ref_no(+)
   and gmr.internal_gmr_ref_no = sd.internal_gmr_ref_no(+)
   and nvl(gmr.is_settlement_gmr, 'N') = 'N'
   and nvl(gmr.tolling_gmr_type, 'None Tolling') not in
       ('Input Process', 'Output Process', 'Mark For Tolling',
        'Received Materials', 'Pledge', 'Financial Settlement',
        'Return Material', 'Free Metal Utility')
   and gam.internal_gmr_ref_no = vd.internal_gmr_ref_no(+)
   and vd.status(+) = 'Active'
   and axs_last.internal_action_ref_no = gmr.internal_action_ref_no
   and pdm.product_id = gmr.product_id;
/
create or replace view v_bi_derivative as
select dt.derivative_ref_no,
       dt.int_trade_parent_der_ref_no origional_trade_ref_no,
       dt.parent_int_derivative_ref_no,
       dt.external_ref_no,
       dt.internal_derivative_ref_no,
       dim.underlying_instrument_id,
       null master_contract_id,
       dt.trade_date,
       to_char(dt.trade_date, 'mm-yyyy') trade_month,
       to_char(dt.trade_date, 'yyyy') trade_year,
       akcu.login_name trader,
       dt.trade_type deal_type,
       dim.instrument_name,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                    pdm_qum.decimals) deal_quantity_in_base_unit,
       pdm_qum.qty_unit base_quantity_unit,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * dt.total_lots total_lots,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * dt.open_lots open_lots,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * dt.closed_lots closed_lots,
       null exercised_lots,
       null expired_lots,
       dt.status,
       dt.trade_price deal_price,
       pum.price_unit_name deal_price_unit,
       null strike_price,
       null strike_price_unit,
       null premium_discount,
       null premium_discount_price_unit,
       pm.period_type_name,
       drm.prompt_date prompt_date,
       to_char(drm.prompt_date, 'Mon-yyyy') prompt_month,
       to_char(drm.prompt_date, 'yyyy') prompt_year,
       nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
       bcs.clearing_fee || (case
         when bcs.trade_type = 'Percentage' then
          '% ' || bct.settlement_type
         else
          bct.settlement_type
       end) clearer_comm_type,
       bca.account_name,
       dt.clearer_comm_amt clearer_commission,
       cm_cl_comm.cur_code clearer_commission_unit,
       nvl(phd_broker.company_long_name1, phd_broker.companyname) broker,
       bct.settlement_type broker_comm_type,
       dt.broker_comm_amt broker_commission,
       cm_comm.cur_code broker_commission_ccy,
       null option_type,
       null expiry_date,
       null expiry_month_year,
       pdm.product_desc product,
       null quality_name,
       null market_location,
       null counter_party,
       null average_from_date,
       null average_to_date,
       null payment_term,
       null payment_due_date,
       null internal_trade_no,
       dt.swap_type_1 pay_details,
       dt.swap_type_2 receive_details,
       cpc.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       null trade_basics,
       null price_source_name,
       null price_point_name,
       irmf.instrument_type,
       phd_nomine.companyname nominee,
       dpm.purpose_display_name purpose_name,
       ak.corporate_id,
       ak.corporate_name,
       blm.business_line_name,
       css.strategy_name,
       dt.remarks,
       emt.exchange_name,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                    pdm_qum.decimals) * dt.trade_price contract_value,
       (case
         when cm_val.is_sub_cur = 'Y' then
          scd.main_cur_code
         else
          cm_val.cur_code
       end) contract_value_unit,
       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                      nvl(pum.cur_id,
                                                          pum_sett.cur_id),
                                                      ak.base_cur_id,
                                                      sysdate,
                                                      1),
             4) fx_to_base,
       null priced_qty, --CIQS
       null unprice_qt
  from dt_derivative_trade          dt,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       css_corporate_strategy_setup css,
       ak_corporate                 ak,
       drm_derivative_master        drm,
       phd_profileheaderdetails     phd_broker,
       phd_profileheaderdetails     phd_clr,
       dim_der_instrument_master    dim,
       /*dim_der_instrument_master dim_under,*/
       qum_quantity_unit_master qum,
       qum_quantity_unit_master pdm_qum,
       irm_instrument_type_master irmf,
       pm_period_master pm,
       pdd_product_derivative_def pdd,
       pdm_productmaster pdm,
       pum_price_unit_master pum,
       pum_price_unit_master pum_strik,
       pum_price_unit_master pum_pd,
       cm_currency_master cm_comm,
       cm_currency_master cm_cl_comm,
       cm_currency_master cm_val,
       (select cm.cur_code main_cur_code,
               cm.decimals main_cur_decimal,
               scd.sub_cur_id,
               scd.cur_id main_cur_id,
               scd.factor
          from scd_sub_currency_detail scd, cm_currency_master cm
         where scd.cur_id = cm.cur_id) scd,
       emt_exchangemaster emt,
       ak_corporate_user akcu,
       bca_broker_clearer_account bca,
       dpm_derivative_purpose_master dpm,
       cm_currency_master cmak,
       bct_broker_commission_types bct,
       bcs_broker_commission_setup bcs,
       ps_price_source ps,
       pp_price_point pp,
       pum_price_unit_master pum_sett,
       phd_profileheaderdetails phd_nomine,
       phd_profileheaderdetails phd_cp,
       ucm_unit_conversion_master ucm
 where dt.dr_id = drm.dr_id
   and dt.broker_profile_id = phd_broker.profileid(+)
   and dt.clearer_profile_id = phd_clr.profileid(+)
   and drm.instrument_id = dim.instrument_id
   and dim.instrument_type_id = irmf.instrument_type_id
   and dt.corporate_id = ak.corporate_id
   and drm.period_type_id = pm.period_type_id(+)
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.product_id = pdm.product_id
   and dt.trade_price_unit_id = pum.price_unit_id(+)
   and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
   and dt.broker_comm_cur_id = cm_comm.cur_id(+)
   and dt.clearer_comm_cur_id = cm_cl_comm.cur_id(+)
   and dt.quantity_unit_id = qum.qty_unit_id
   and pdm.base_quantity_unit = pdm_qum.qty_unit_id
   and pum.cur_id = cm_val.cur_id(+)
   and dt.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id(+)
   and cm_val.cur_id = scd.sub_cur_id(+)
   and dt.strategy_id = css.strategy_id(+)
   and irmf.is_active = 'Y'
   and irmf.is_deleted = 'N'
   and dt.status = 'Verified'
   /*and emt.exchange_code = 'LME' */
   and pdd.exchange_id = emt.exchange_id
   and akcu.user_id = dt.trader_id
   and bca.account_id = dt.clearer_account_id
   and dpm.purpose_id = dt.purpose_id
   and cmak.cur_id = ak.base_cur_id
   and dt.clearer_comm_type_id = bct.commission_type_id(+)
   and bct.commission_type_id = bcs.commission_type_id(+)
   and dim.instrument_type_id = bcs.future_option_type
   and dt.price_source_id = ps.price_source_id(+)
   and dt.price_point_id = pp.price_point_id(+)
   and dt.settlement_price_unit_id = pum_sett.price_unit_id(+)
   and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
   and dt.traded_on = 'Exchange'
   and nvl(dt.is_internal_trade, 'N') = 'N'
   and dt.nominee_profile_id = phd_nomine.profileid(+)
   and dt.cp_profile_id = phd_cp.profileid(+)
   and dt.quantity_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
union all
select t.derivative_ref_no,
       t.origional_trade_ref_no,
       t.parent_int_derivative_ref_no,
       t.external_ref_no,
       t.internal_derivative_ref_no,
       t.underlying_instrument_id,
       t.master_contract_id,
       t.trade_date,
       t.trade_month,
       t.trade_year,
       t. trader,
       t.deal_type,
       t.instrument_name,
       t.deal_quantity_in_base_unit,
       t.base_quantity_unit,
       t.total_lots,
       t.open_lots,
       t.closed_lots,
       t.exercised_lots,
       t.expired_lots,
       t.status,
       t.deal_price,
       t.deal_price_unit,
       t.strike_price,
       t.strike_price_unit,
       t.premium_discount,
       t.premium_discount_price_unit,
       t.period_type_name,
       t. prompt_date,
       t. prompt_month,
       t.prompt_year,
       t. clearer,
       bcs.clearing_fee || (case
         when bcs.trade_type = 'Percentage' then
          '% ' || t.settlement_type
         else
          t.settlement_type
       end) clearer_comm_type,
       t.account_name,
       t.clearer_commission,
       t.clearer_commission_unit,
       t. broker,
       t. broker_comm_type,
       t. broker_commission,
       t. broker_commission_ccy,
       t. option_type,
       t.expiry_date,
       t. expiry_month_year,
       t. product,
       t.quality_name,
       t. market_location,
       t. counter_party,
       t.average_from_date,
       t.average_to_date,
       t.payment_term,
       t.payment_due_date,
       t. internal_trade_no,
       t. pay_details,
       t. receive_details,
       t.profit_center_id,
       t.profit_center_name,
       t.profit_center_short_name,
       t. trade_basics,
       t.price_source_name,
       t.price_point_name,
       t.instrument_type,
       t. nominee,
       t. purpose_name,
       t.corporate_id cor_id,
       t.corporate_name,
       t.business_line_name,
       t.strategy_name,
       t.remarks,
       null exchnage_name,
       t. contract_value,
       t. contract_value_unit,
       t. fx_to_base,
       t. priced_qty,
       t. unprice_qt
  from (select dt.derivative_ref_no,
               dt.int_trade_parent_der_ref_no origional_trade_ref_no,
               dt.parent_int_derivative_ref_no,
               dt.external_ref_no,
               dt.internal_derivative_ref_no,
               dim.underlying_instrument_id,
               dt.master_contract_id,
               dt.trade_date,
               to_char(dt.trade_date, 'mm-yyyy') trade_month,
               to_char(dt.trade_date, 'yyyy') trade_year,
               akcu.login_name trader,
               dt.trade_type deal_type,
               dim.instrument_name,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) *
               round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                     pdm_qum.decimals) deal_quantity_in_base_unit,
               pdm_qum.qty_unit base_quantity_unit,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.total_lots total_lots,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.open_lots open_lots,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.closed_lots closed_lots,
               dt.exercised_lots,
               dt.expired_lots,
               dt.status,
               dt.trade_price deal_price,
               pum.price_unit_name deal_price_unit,
               dt.strike_price,
               pum_strik.price_unit_name strike_price_unit,
               dt.premium_discount,
               pum_pd.price_unit_name premium_discount_price_unit,
               pm.period_type_name,
               drm.prompt_date prompt_date,
               to_char(drm.prompt_date, 'Mon-yyyy') prompt_month,
               to_char(drm.prompt_date, 'yyyy') prompt_year,
               nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
               bct.settlement_type,
               bca.account_name,
               dt.clearer_comm_amt clearer_commission,
               cm_cl_comm.cur_code clearer_commission_unit,
               nvl(phd_broker.company_long_name1, phd_broker.companyname) broker,
               bct.settlement_type broker_comm_type,
               dt.broker_comm_amt broker_commission,
               cm_comm.cur_code broker_commission_ccy,
               irmf.instrument_type option_type,
               drm.expiry_date,
               to_char(drm.expiry_date, 'Mon-yyyy') expiry_month_year,
               pdm.product_desc product,
               qat.quality_name,
               (case
                 when cym.country_name || ',  ' || sm.state_name || ', ' ||
                      cim.city_name = ',  , ' then
                  null
                 else
                  cym.country_name || ',  ' || sm.state_name || ', ' ||
                  cim.city_name
               end) market_location,
               phd_cp.companyname counter_party,
               dt.average_from_date,
               dt.average_to_date,
               dt.payment_term,
               dt.payment_due_date,
               dt.internal_derivative_ref_no internal_trade_no,
               dt.swap_type_1 pay_details,
               dt.swap_type_2 receive_details,
               cpc.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               dt.trade_price_type_id trade_basics,
               bct.commission_type_id,
               dt.corporate_id,
               dim.instrument_type_id,
               ps.price_source_name,
               pp.price_point_name,
               irmf.instrument_type,
               phd_nomine.companyname nominee, --
               dpm.purpose_display_name purpose_name,
               ak.corporate_id cor_id,
               ak.corporate_name,
               blm.business_line_name,
               css.strategy_name,
               dt.remarks,
               null exchange_name,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) *
               round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                     pdm_qum.decimals) * dt.trade_price contract_value,
               (case
                 when cm_val.is_sub_cur = 'Y' then
                  scd.main_cur_code
                 else
                  cm_val.cur_code
               end) contract_value_unit,
               round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                              nvl(pum.cur_id,
                                                                  pum_sett.cur_id),
                                                              ak.base_cur_id,
                                                              sysdate,
                                                              1),
                     4) fx_to_base,
               null priced_qty,
               null unprice_qt
        
          from dt_derivative_trade dt,
               cpc_corporate_profit_center cpc,
               blm_business_line_master blm,
               css_corporate_strategy_setup css,
               ak_corporate ak,
               drm_derivative_master drm,
               phd_profileheaderdetails phd_broker,
               phd_profileheaderdetails phd_clr,
               dim_der_instrument_master dim,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master pdm_qum,
               irm_instrument_type_master irmf,
               pm_period_master pm,
               pdd_product_derivative_def pdd,
               pdm_productmaster pdm,
               pum_price_unit_master pum,
               pum_price_unit_master pum_strik,
               pum_price_unit_master pum_pd,
               cm_currency_master cm_comm,
               cm_currency_master cm_cl_comm,
               cm_currency_master cm_val,
               (select cm.cur_code main_cur_code,
                       cm.decimals main_cur_decimal,
                       scd.sub_cur_id,
                       scd.cur_id main_cur_id,
                       scd.factor
                  from scd_sub_currency_detail scd, cm_currency_master cm
                 where scd.cur_id = cm.cur_id) scd,
               ak_corporate_user akcu,
               bca_broker_clearer_account bca,
               dpm_derivative_purpose_master dpm,
               cm_currency_master cmak,
               bct_broker_commission_types bct,
               qat_quality_attributes qat,
               ps_price_source ps,
               pp_price_point pp,
               pum_price_unit_master pum_sett,
               phd_profileheaderdetails phd_nomine,
               phd_profileheaderdetails phd_cp,
               ucm_unit_conversion_master ucm,
               cym_countrymaster cym,
               sm_state_master sm,
               cim_citymaster cim
         where dt.dr_id = drm.dr_id
           and dt.broker_profile_id = phd_broker.profileid(+)
           and dt.clearer_profile_id = phd_clr.profileid(+)
           and drm.instrument_id = dim.instrument_id
           and dim.instrument_type_id = irmf.instrument_type_id
           and dt.corporate_id = ak.corporate_id
           and drm.period_type_id = pm.period_type_id(+)
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.product_id = pdm.product_id
           and dt.trade_price_unit_id = pum.price_unit_id(+)
           and dt.broker_comm_cur_id = cm_comm.cur_id(+)
           and dt.clearer_comm_cur_id = cm_cl_comm.cur_id(+)
           and dt.quantity_unit_id = qum.qty_unit_id
           and pdm.base_quantity_unit = pdm_qum.qty_unit_id
           and pum.cur_id = cm_val.cur_id(+)
           and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
           and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
           and dt.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and cm_val.cur_id = scd.sub_cur_id(+)
           and dt.strategy_id = css.strategy_id(+)
           and irmf.is_active = 'Y'
           and irmf.is_deleted = 'N'
           and dt.status = 'Verified'
           and akcu.user_id = dt.trader_id
           and dt.clearer_account_id = bca.account_id(+)
           and dpm.purpose_id = dt.purpose_id
           and cmak.cur_id = ak.base_cur_id
           and dt.clearer_comm_type_id = bct.commission_type_id(+)
           and dt.quality_id = qat.quality_id(+)
          /*and qat.instrument_id = pdd.derivative_def_id
           and pdm.product_id = qat.product_id
           and qat.instrument_id = pdd.derivative_def_id(+)*/
           and dt.price_source_id = ps.price_source_id(+)
           and dt.price_point_id = pp.price_point_id(+)
           and dt.settlement_price_unit_id = pum_sett.price_unit_id(+)
           and nvl(dt.traded_on, 'OTC') = 'OTC'
           and dt.nominee_profile_id = phd_nomine.profileid(+)
           and dt.cp_profile_id = phd_cp.profileid(+)
           and dt.quantity_unit_id = ucm.from_qty_unit_id
           and pdm.base_quantity_unit = ucm.to_qty_unit_id
           and dt.market_location_country = cym.country_id(+)
           and dt.market_location_state = sm.state_id(+)
           and dt.market_location_city = cim.city_id(+)) t,
       bcs_broker_commission_setup bcs
 where t.commission_type_id = bcs.commission_type_id(+)
   and t.corporate_id = bcs.corporate_id(+)
   and bcs.future_option_type(+) = t.instrument_type_id;
/
create or replace view v_bi_derivative as
select dt.derivative_ref_no,
       dt.int_trade_parent_der_ref_no origional_trade_ref_no,
       dt.parent_int_derivative_ref_no,
       dt.external_ref_no,
       dt.internal_derivative_ref_no,
       dim.underlying_instrument_id,
       null master_contract_id,
       dt.trade_date,
       to_char(dt.trade_date, 'mm-yyyy') trade_month,
       to_char(dt.trade_date, 'yyyy') trade_year,
       akcu.login_name trader,
       dt.trade_type deal_type,
       dim.instrument_name,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                    pdm_qum.decimals) deal_quantity_in_base_unit,
       pdm_qum.qty_unit base_quantity_unit,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * dt.total_lots total_lots,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * dt.open_lots open_lots,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * dt.closed_lots closed_lots,
       null exercised_lots,
       null expired_lots,
       dt.status,
       dt.trade_price deal_price,
       pum.price_unit_name deal_price_unit,
       null strike_price,
       null strike_price_unit,
       null premium_discount,
       null premium_discount_price_unit,
       pm.period_type_name,
       drm.prompt_date prompt_date,
       to_char(drm.prompt_date, 'Mon-yyyy') prompt_month,
       to_char(drm.prompt_date, 'yyyy') prompt_year,
       nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
       bcs.clearing_fee || (case
         when bcs.trade_type = 'Percentage' then
          '% ' || bct.settlement_type
         else
          bct.settlement_type
       end) clearer_comm_type,
       bca.account_name,
       dt.clearer_comm_amt clearer_commission,
       cm_cl_comm.cur_code clearer_commission_unit,
       nvl(phd_broker.company_long_name1, phd_broker.companyname) broker,
       bct.settlement_type broker_comm_type,
       dt.broker_comm_amt broker_commission,
       cm_comm.cur_code broker_commission_ccy,
       null option_type,
       null expiry_date,
       null expiry_month_year,
       pdm.product_desc product,
       null quality_name,
       null market_location,
       null counter_party,
       null average_from_date,
       null average_to_date,
       null payment_term,
       null payment_due_date,
       null internal_trade_no,
       dt.swap_type_1 pay_details,
       dt.swap_type_2 receive_details,
       cpc.profit_center_id,
       cpc.profit_center_name,
       cpc.profit_center_short_name,
       null trade_basics,
       null price_source_name,
       null price_point_name,
       irmf.instrument_type,
       phd_nomine.companyname nominee,
       dpm.purpose_display_name purpose_name,
       ak.corporate_id,
       ak.corporate_name,
       blm.business_line_name,
       css.strategy_name,
       dt.remarks,
       emt.exchange_name,
       (case
         when dt.trade_type = 'Sell' then
          -1
         else
          1
       end) * round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                    pdm_qum.decimals) * dt.trade_price contract_value,
       (case
         when cm_val.is_sub_cur = 'Y' then
          scd.main_cur_code
         else
          cm_val.cur_code
       end) contract_value_unit,
       round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                      nvl(pum.cur_id,
                                                          pum_sett.cur_id),
                                                      ak.base_cur_id,
                                                      sysdate,
                                                      1),
             4) fx_to_base,
       null priced_qty, --CIQS
       null unprice_qt
  from dt_derivative_trade          dt,
       cpc_corporate_profit_center  cpc,
       blm_business_line_master     blm,
       css_corporate_strategy_setup css,
       ak_corporate                 ak,
       drm_derivative_master        drm,
       phd_profileheaderdetails     phd_broker,
       phd_profileheaderdetails     phd_clr,
       dim_der_instrument_master    dim,
       /*dim_der_instrument_master dim_under,*/
       qum_quantity_unit_master qum,
       qum_quantity_unit_master pdm_qum,
       irm_instrument_type_master irmf,
       pm_period_master pm,
       pdd_product_derivative_def pdd,
       pdm_productmaster pdm,
       pum_price_unit_master pum,
       pum_price_unit_master pum_strik,
       pum_price_unit_master pum_pd,
       cm_currency_master cm_comm,
       cm_currency_master cm_cl_comm,
       cm_currency_master cm_val,
       (select cm.cur_code main_cur_code,
               cm.decimals main_cur_decimal,
               scd.sub_cur_id,
               scd.cur_id main_cur_id,
               scd.factor
          from scd_sub_currency_detail scd, cm_currency_master cm
         where scd.cur_id = cm.cur_id) scd,
       emt_exchangemaster emt,
       ak_corporate_user akcu,
       bca_broker_clearer_account bca,
       dpm_derivative_purpose_master dpm,
       cm_currency_master cmak,
       bct_broker_commission_types bct,
       bcs_broker_commission_setup bcs,
       ps_price_source ps,
       pp_price_point pp,
       pum_price_unit_master pum_sett,
       phd_profileheaderdetails phd_nomine,
       phd_profileheaderdetails phd_cp,
       ucm_unit_conversion_master ucm
 where dt.dr_id = drm.dr_id
   and dt.broker_profile_id = phd_broker.profileid(+)
   and dt.clearer_profile_id = phd_clr.profileid(+)
   and drm.instrument_id = dim.instrument_id
   and dim.instrument_type_id = irmf.instrument_type_id
   and dt.corporate_id = ak.corporate_id
   and drm.period_type_id = pm.period_type_id(+)
   and dim.product_derivative_id = pdd.derivative_def_id
   and pdd.product_id = pdm.product_id
   and dt.trade_price_unit_id = pum.price_unit_id(+)
   and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
   and dt.broker_comm_cur_id = cm_comm.cur_id(+)
   and dt.clearer_comm_cur_id = cm_cl_comm.cur_id(+)
   and dt.quantity_unit_id = qum.qty_unit_id
   and pdm.base_quantity_unit = pdm_qum.qty_unit_id
   and pum.cur_id = cm_val.cur_id(+)
   and dt.profit_center_id = cpc.profit_center_id
   and cpc.business_line_id = blm.business_line_id(+)
   and cm_val.cur_id = scd.sub_cur_id(+)
   and dt.strategy_id = css.strategy_id(+)
   and irmf.is_active = 'Y'
   and irmf.is_deleted = 'N'
   and dt.status = 'Verified'
   /*and emt.exchange_code = 'LME' */
   and pdd.exchange_id = emt.exchange_id
   and akcu.user_id = dt.trader_id
   and bca.account_id = dt.clearer_account_id
   and dpm.purpose_id = dt.purpose_id
   and cmak.cur_id = ak.base_cur_id
   and dt.clearer_comm_type_id = bct.commission_type_id(+)
   and bct.commission_type_id = bcs.commission_type_id(+)
   and dim.instrument_type_id = bcs.future_option_type
   and dt.price_source_id = ps.price_source_id(+)
   and dt.price_point_id = pp.price_point_id(+)
   and dt.settlement_price_unit_id = pum_sett.price_unit_id(+)
   and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
   and dt.traded_on = 'Exchange'
   and nvl(dt.is_internal_trade, 'N') = 'N'
   and dt.nominee_profile_id = phd_nomine.profileid(+)
   and dt.cp_profile_id = phd_cp.profileid(+)
   and dt.quantity_unit_id = ucm.from_qty_unit_id
   and pdm.base_quantity_unit = ucm.to_qty_unit_id
union all
select t.derivative_ref_no,
       t.origional_trade_ref_no,
       t.parent_int_derivative_ref_no,
       t.external_ref_no,
       t.internal_derivative_ref_no,
       t.underlying_instrument_id,
       t.master_contract_id,
       t.trade_date,
       t.trade_month,
       t.trade_year,
       t. trader,
       t.deal_type,
       t.instrument_name,
       t.deal_quantity_in_base_unit,
       t.base_quantity_unit,
       t.total_lots,
       t.open_lots,
       t.closed_lots,
       t.exercised_lots,
       t.expired_lots,
       t.status,
       t.deal_price,
       t.deal_price_unit,
       t.strike_price,
       t.strike_price_unit,
       t.premium_discount,
       t.premium_discount_price_unit,
       t.period_type_name,
       t. prompt_date,
       t. prompt_month,
       t.prompt_year,
       t. clearer,
       bcs.clearing_fee || (case
         when bcs.trade_type = 'Percentage' then
          '% ' || t.settlement_type
         else
          t.settlement_type
       end) clearer_comm_type,
       t.account_name,
       t.clearer_commission,
       t.clearer_commission_unit,
       t. broker,
       t. broker_comm_type,
       t. broker_commission,
       t. broker_commission_ccy,
       t. option_type,
       t.expiry_date,
       t. expiry_month_year,
       t. product,
       t.quality_name,
       t. market_location,
       t. counter_party,
       t.average_from_date,
       t.average_to_date,
       t.payment_term,
       t.payment_due_date,
       t. internal_trade_no,
       t. pay_details,
       t. receive_details,
       t.profit_center_id,
       t.profit_center_name,
       t.profit_center_short_name,
       t. trade_basics,
       t.price_source_name,
       t.price_point_name,
       t.instrument_type,
       t. nominee,
       t. purpose_name,
       t.corporate_id cor_id,
       t.corporate_name,
       t.business_line_name,
       t.strategy_name,
       t.remarks,
       null exchnage_name,
       t. contract_value,
       t. contract_value_unit,
       t. fx_to_base,
       t. priced_qty,
       t. unprice_qt
  from (select dt.derivative_ref_no,
               dt.int_trade_parent_der_ref_no origional_trade_ref_no,
               dt.parent_int_derivative_ref_no,
               dt.external_ref_no,
               dt.internal_derivative_ref_no,
               dim.underlying_instrument_id,
               dt.master_contract_id,
               dt.trade_date,
               to_char(dt.trade_date, 'mm-yyyy') trade_month,
               to_char(dt.trade_date, 'yyyy') trade_year,
               akcu.login_name trader,
               dt.trade_type deal_type,
               dim.instrument_name,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) *
               round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                     pdm_qum.decimals) deal_quantity_in_base_unit,
               pdm_qum.qty_unit base_quantity_unit,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.total_lots total_lots,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.open_lots open_lots,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) * dt.closed_lots closed_lots,
               dt.exercised_lots,
               dt.expired_lots,
               dt.status,
               dt.trade_price deal_price,
               pum.price_unit_name deal_price_unit,
               dt.strike_price,
               pum_strik.price_unit_name strike_price_unit,
               dt.premium_discount,
               pum_pd.price_unit_name premium_discount_price_unit,
               pm.period_type_name,
               drm.prompt_date prompt_date,
               to_char(drm.prompt_date, 'Mon-yyyy') prompt_month,
               to_char(drm.prompt_date, 'yyyy') prompt_year,
               nvl(phd_clr.company_long_name1, phd_clr.companyname) clearer,
               bct.settlement_type,
               bca.account_name,
               dt.clearer_comm_amt clearer_commission,
               cm_cl_comm.cur_code clearer_commission_unit,
               nvl(phd_broker.company_long_name1, phd_broker.companyname) broker,
               bct.settlement_type broker_comm_type,
               dt.broker_comm_amt broker_commission,
               cm_comm.cur_code broker_commission_ccy,
               irmf.instrument_type option_type,
               drm.expiry_date,
               to_char(drm.expiry_date, 'Mon-yyyy') expiry_month_year,
               pdm.product_desc product,
               qat.quality_name,
               (case
                 when cym.country_name || ',  ' || sm.state_name || ', ' ||
                      cim.city_name = ',  , ' then
                  null
                 else
                  cym.country_name || ',  ' || sm.state_name || ', ' ||
                  cim.city_name
               end) market_location,
               phd_cp.companyname counter_party,
               dt.average_from_date,
               dt.average_to_date,
               dt.payment_term,
               dt.payment_due_date,
               dt.internal_derivative_ref_no internal_trade_no,
               dt.swap_type_1 pay_details,
               dt.swap_type_2 receive_details,
               cpc.profit_center_id,
               cpc.profit_center_name,
               cpc.profit_center_short_name,
               dt.trade_price_type_id trade_basics,
               bct.commission_type_id,
               dt.corporate_id,
               dim.instrument_type_id,
               ps.price_source_name,
               pp.price_point_name,
               irmf.instrument_type,
               phd_nomine.companyname nominee, --
               dpm.purpose_display_name purpose_name,
               ak.corporate_id cor_id,
               ak.corporate_name,
               blm.business_line_name,
               css.strategy_name,
               dt.remarks,
               null exchange_name,
               (case
                 when dt.trade_type = 'Sell' then
                  -1
                 else
                  1
               end) *
               round((dt.total_quantity * nvl(ucm.multiplication_factor, 1)),
                     pdm_qum.decimals) * dt.trade_price contract_value,
               (case
                 when cm_val.is_sub_cur = 'Y' then
                  scd.main_cur_code
                 else
                  cm_val.cur_code
               end) contract_value_unit,
               round(pkg_general.f_get_converted_currency_amt(dt.corporate_id,
                                                              nvl(pum.cur_id,
                                                                  pum_sett.cur_id),
                                                              ak.base_cur_id,
                                                              sysdate,
                                                              1),
                     4) fx_to_base,
               null priced_qty,
               null unprice_qt
        
          from dt_derivative_trade dt,
               cpc_corporate_profit_center cpc,
               blm_business_line_master blm,
               css_corporate_strategy_setup css,
               ak_corporate ak,
               drm_derivative_master drm,
               phd_profileheaderdetails phd_broker,
               phd_profileheaderdetails phd_clr,
               dim_der_instrument_master dim,
               qum_quantity_unit_master qum,
               qum_quantity_unit_master pdm_qum,
               irm_instrument_type_master irmf,
               pm_period_master pm,
               pdd_product_derivative_def pdd,
               pdm_productmaster pdm,
               pum_price_unit_master pum,
               pum_price_unit_master pum_strik,
               pum_price_unit_master pum_pd,
               cm_currency_master cm_comm,
               cm_currency_master cm_cl_comm,
               cm_currency_master cm_val,
               (select cm.cur_code main_cur_code,
                       cm.decimals main_cur_decimal,
                       scd.sub_cur_id,
                       scd.cur_id main_cur_id,
                       scd.factor
                  from scd_sub_currency_detail scd, cm_currency_master cm
                 where scd.cur_id = cm.cur_id) scd,
               ak_corporate_user akcu,
               bca_broker_clearer_account bca,
               dpm_derivative_purpose_master dpm,
               cm_currency_master cmak,
               bct_broker_commission_types bct,
               qat_quality_attributes qat,
               ps_price_source ps,
               pp_price_point pp,
               pum_price_unit_master pum_sett,
               phd_profileheaderdetails phd_nomine,
               phd_profileheaderdetails phd_cp,
               ucm_unit_conversion_master ucm,
               cym_countrymaster cym,
               sm_state_master sm,
               cim_citymaster cim
         where dt.dr_id = drm.dr_id
           and dt.broker_profile_id = phd_broker.profileid(+)
           and dt.clearer_profile_id = phd_clr.profileid(+)
           and drm.instrument_id = dim.instrument_id
           and dim.instrument_type_id = irmf.instrument_type_id
           and dt.corporate_id = ak.corporate_id
           and drm.period_type_id = pm.period_type_id(+)
           and dim.product_derivative_id = pdd.derivative_def_id
           and pdd.product_id = pdm.product_id
           and dt.trade_price_unit_id = pum.price_unit_id(+)
           and dt.broker_comm_cur_id = cm_comm.cur_id(+)
           and dt.clearer_comm_cur_id = cm_cl_comm.cur_id(+)
           and dt.quantity_unit_id = qum.qty_unit_id
           and pdm.base_quantity_unit = pdm_qum.qty_unit_id
           and pum.cur_id = cm_val.cur_id(+)
           and dt.strike_price_unit_id = pum_strik.price_unit_id(+)
           and dt.premium_discount_price_unit_id = pum_pd.price_unit_id(+)
           and dt.profit_center_id = cpc.profit_center_id
           and cpc.business_line_id = blm.business_line_id(+)
           and cm_val.cur_id = scd.sub_cur_id(+)
           and dt.strategy_id = css.strategy_id(+)
           and irmf.is_active = 'Y'
           and irmf.is_deleted = 'N'
           and dt.status = 'Verified'
           and akcu.user_id = dt.trader_id
           and dt.clearer_account_id = bca.account_id(+)
           and dpm.purpose_id = dt.purpose_id
           and cmak.cur_id = ak.base_cur_id
           and dt.clearer_comm_type_id = bct.commission_type_id(+)
           and dt.quality_id = qat.quality_id(+)
          /*and qat.instrument_id = pdd.derivative_def_id
           and pdm.product_id = qat.product_id
           and qat.instrument_id = pdd.derivative_def_id(+)*/
           and dt.price_source_id = ps.price_source_id(+)
           and dt.price_point_id = pp.price_point_id(+)
           and dt.settlement_price_unit_id = pum_sett.price_unit_id(+)
           and nvl(dt.traded_on, 'OTC') = 'OTC'
           and dt.nominee_profile_id = phd_nomine.profileid(+)
           and dt.cp_profile_id = phd_cp.profileid(+)
           and dt.quantity_unit_id = ucm.from_qty_unit_id
           and pdm.base_quantity_unit = ucm.to_qty_unit_id
           and dt.market_location_country = cym.country_id(+)
           and dt.market_location_state = sm.state_id(+)
           and dt.market_location_city = cim.city_id(+)) t,
       bcs_broker_commission_setup bcs
 where t.commission_type_id = bcs.commission_type_id(+)
   and t.corporate_id = bcs.corporate_id(+)
   and bcs.future_option_type(+) = t.instrument_type_id ;
/
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('256', '11', 'BrokerMarginReport.rpt', 'Broker Margin  Report', NULL, 
    NULL, NULL, 'populateFilter', 'ONLINE', 'Y');
COMMIT;

insert into ref_reportexportformat (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
values ('256', 'EXCEL', 'BrokerMarginReport.rpt');


Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D256', 'Broker Margin  Report', 33, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=ONLINE&ReportID=256&ReportName=BrokerMarginReport.rpt&ExportFormat=HTML', 
    NULL, 'RPT-D21', NULL, 'Reports', NULL, 
    'N');
COMMIT;
drop materialized view MV_FACT_BROKER_MARGIN_UTIL;
create materialized view MV_FACT_BROKER_MARGIN_UTIL
refresh force on demand
as
select tdc.process_id,
       tdc.trade_date eod_date,
       tdc.corporate_id,
       bmu.corporate_name,
       bmu.broker_profile_id,
       bmu.broker_name,
       bmu.instrument_id,
       bmu.instrument_name,
       bmu.exchange_id,
       bmu.exchange_name,
       bmu.margin_cur_id,
       bmu.margin_cur_code,
       bmu.initial_margin_limit,
       bmu.current_credit_limit,
       bmu.variation_margin_limit,
       bmu.maintenance_margin,
       bmu.margin_calculation_method,
       bmu.base_cur_id,
       bmu.base_cur_code,
       bmu.fx_rate_margin_cur_to_base_cur,
       bmu.initial_margin_limit_in_base,
       bmu.current_credit_limit_in_base,
       bmu.variation_margin_limit_in_base,
       bmu.maintenance_margin_in_base,
       bmu.no_of_lots,
       bmu.net_no_of_lots,
       bmu.gross_no_of_lots,
       bmu.initial_margin_rate_cur_id,
       bmu.initial_margin_rate_cur_code,
       bmu.initial_margin_rate,
       bmu.initial_margin_requirement,
       bmu.fx_rate_imr_cur_to_base_cur,
       bmu.initial_margin_req_in_base,
       bmu.under_over_utilized_im,
       bmu.under_over_utilized_im_flag,
       bmu.trade_value_in_base,
       bmu.market_value_in_base,
       bmu.open_no_of_lots,
       bmu.lot_size,
       bmu.lot_size_unit,
       bmu.variation_margin_requirement,
       bmu.under_over_utilized_vm,
       bmu.under_over_utilized_vm_flag
  from bmu_broker_margin_utilization@eka_eoddb bmu,
       tdc_trade_date_closure@eka_eoddb        tdc
 where bmu.corporate_id = tdc.corporate_id
   and bmu.process_id = tdc.process_id;
/
delete from rpc_rf_parameter_config rpc where rpc.report_id = 256;
delete from rfc_report_filter_config rfc where rfc.report_id = 256;
commit;
SET DEFINE OFF;
begin
for cc in (select  akc.corporate_id  from ak_corporate akc where akc.is_active = 'Y' and akc.is_internal_corporate = 'N')
loop
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 1, 1, 
    'Trade Date', 'GFF021', 1, 'Y');

Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP0104', 'SYSTEM');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '256', 'RFC256PHY01', 'RFP0026', 'AsOfDate');

end loop;
commit;
end;
/
-- Create table
--DROP TABLE EOD_EOM_PROCESS_COUNT;
create table EOD_EOM_PROCESS_COUNT
(
  CORPORATE_ID               VARCHAR2(15),
  TRADE_DATE                 DATE,
  PROCESS                    VARCHAR2(5),
  CREATED_DATE               TIMESTAMP(6),
  processing_status          VARCHAR2(100)
  
);
create or replace package "PKG_EXECUTE_EOD" is

  procedure sp_execute_eod(pc_corporate_id       varchar2,
                           pc_action             varchar2,
                           pt_previous_pull_date timestamp,
                           pt_current_pull_date  timestamp,
                           pc_user_id            varchar2,
                           pd_trade_date         date,
                           pc_eod_status         out varchar2);

  procedure sp_record_cost(pc_corporate_id varchar2, pd_trade_date date);

  procedure sp_record_expired_drid(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process      varchar2);

  procedure sp_insert_eod_error_log(pc_corporate_id     varchar2,
                                    pc_submodule_name   varchar2,
                                    pc_exception_code   varchar2,
                                    pc_data_missing_for varchar2,
                                    pc_trade_ref_no     varchar2,
                                    pc_process          varchar2,
                                    pc_process_run_by   varchar2,
                                    pd_trade_date       date);

  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date);
  procedure sp_mark_process_status(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process      varchar2,
                                   pc_action       varchar2,
                                   pc_eod_status   varchar2);
  procedure sp_mark_process_count(pc_corporate_id varchar2,
                                  pc_process      varchar2,
                                  pd_trade_date   date);

  procedure sp_refresh_mv;
end pkg_execute_eod;
/
create or replace package body "PKG_EXECUTE_EOD" is

  procedure sp_execute_eod(pc_corporate_id       in varchar2,
                           pc_action             varchar2,
                           pt_previous_pull_date timestamp,
                           pt_current_pull_date  timestamp,
                           pc_user_id            varchar2,
                           pd_trade_date         date,
                           pc_eod_status         out varchar2) is
    vn_error_count            number;
    vn_error_only_error_count number;
    vc_process_status         varchar2(10) := 'NA';
  begin
    vn_error_count            := 0;
    vn_error_only_error_count := 0;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'Before calling EOD sp_execute_process, pc_action ' ||
                          pc_action || ' pt_previous_pull_date ' ||
                          pt_previous_pull_date || ' pt_current_pull_date ' ||
                          pt_current_pull_date,
                          1);
    pkg_execute_process.sp_execute_process@eka_eoddb(pc_corporate_id,
                                                     pc_action,
                                                     'EOD',
                                                     pt_previous_pull_date,
                                                     pt_current_pull_date,
                                                     pc_user_id,
                                                     pd_trade_date);
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'Before calling sp_mark_dumps_status',
                          2);
    sp_mark_dumps_status(pc_corporate_id, pd_trade_date);
  
    begin
      select count(*)
        into vn_error_count
        from eel_eod_eom_exception_log@eka_eoddb eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = 'EOD'
         and nvl(eel.error_type, 'Error') = 'Error'
         and eel.trade_date = pd_trade_date;
      select count(*)
        into vn_error_only_error_count
        from eel_eod_eom_exception_log@eka_eoddb eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = 'EOD'
         and eel.trade_date = pd_trade_date
         and nvl(eel.error_type, 'Error') = 'Error';
    exception
      when others then
        pc_eod_status             := 'Code:' || sqlcode || 'Message:' ||
                                     sqlerrm;
        vn_error_count            := 0;
        vn_error_only_error_count := 0;
    end;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'error count check completed ' ||
                          ' vn_error_count =' || vn_error_count ||
                          ' vn_error_only_error_count ' ||
                          vn_error_only_error_count || ' pc_eod_status ' ||
                          pc_eod_status,
                          3);
    if pc_action = 'PRECHECK' then
      if vn_error_count = 0 then
        pc_eod_status := 'Precheck Success, Run the EOD';
      else
        if vn_error_only_error_count > 0 then
          pc_eod_status := 'Precheck Completed, User input required';
        else
          pc_eod_status := 'Precheck Completed With Warnings';
        end if;
      end if;
    elsif pc_action = 'PRECHECK_RUN' then
      if vn_error_count = 0 then
        pc_eod_status := 'EOD Process Success,Awaiting Cost Entry';
        --Everything OK, Let us settle trades in Transaction Schema
        sp_record_expired_drid(pc_corporate_id, pd_trade_date, 'EOD');
      else
        if vn_error_only_error_count > 0 then
          pc_eod_status := 'Precheck Completed, User input required';
        else
          pc_eod_status := 'Precheck Completed With Warnings';
        end if;
      end if;
    elsif pc_action = 'RUN' then
      if vn_error_count = 0 then
        pc_eod_status := 'EOD Process Success,Awaiting Cost Entry';
        --Everything OK, Let us settle trades in Transaction Schema
        sp_record_expired_drid(pc_corporate_id, pd_trade_date, 'EOD');
      else
        pc_eod_status := 'EOD Process Failed';
      end if;
    end if;
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          ' End of execute eod pkg ' || ' pc_eod_status ' ||
                          pc_eod_status,
                          4);
    vc_process_status := pkg_process_status.sp_get@eka_eoddb(pc_corporate_id,
                                                             'EOD',
                                                             pd_trade_date);
    if vc_process_status = 'Cancel' then
      pc_eod_status := 'EOD Cancelled';
    end if;
    sp_mark_process_status(pc_corporate_id,
                           pd_trade_date,
                           'EOD',
                           pc_action,
                           pc_eod_status);
    sp_refresh_mv;
    if pc_eod_status in ('EOD Processed Successfully',
        'EOD Process Success,Awaiting Cost Entry',
        'EOM Processed Successfully',
        'EOM Process Success,Awaiting Cost Entry') then
      sp_mark_process_count(pc_corporate_id, 'EOD', pd_trade_date);
    end if;
  exception
    when others then
      sp_mark_process_status(pc_corporate_id,
                             pd_trade_date,
                             'EOD',
                             pc_action,
                             pc_eod_status);
  end;

  procedure sp_record_cost(pc_corporate_id varchar2, pd_trade_date date) is
  begin
    begin
      pkg_execute_process.sp_record_misc_cost@eka_eoddb(pc_corporate_id,
                                                        pd_trade_date,
                                                        'EOD');
    
    end;
  end;

  procedure sp_record_expired_drid
  --------------------------------------------------------------------------------------------------------------------------
    --        Procedure Name                            : sp_settle_future_trades
    --        Author                                    : Janna
    --        Created Date                              : 14th July 2009
    --        Purpose                                   : Updates Future Trades as Settled once EOD is completed
    --
    --        Description                               : Trades are marked as Settled first in
    --                                                    EOD schema. The currency trades which are settled
    --                                                    in this EOD are stored in SFT table
    --        Parameters
    --        pc_corporate_id                           : Corporate ID
    --        pd_trade_date                             : EOD Date
    --
    --        Modification History
    --        Modified Date                             :
    --        Modified By                               :
    --        Modify Description                        :
    --------------------------------------------------------------------------------------------------------------------------
  (pc_corporate_id varchar2, pd_trade_date date, pc_process varchar2) is
  begin
    --siva commented below to do
    /*update ct_currency_trade ct
    set    ct.status = 'SETTLED'
    where  ct.ct_id in (select ct_id
                        from   eci_expired_ct_id@eka_eoddb
                        where  corporate_id = pc_corporate_id and
                               trade_date >
                               (select max(trade_date)
                                from   tdc_trade_date_closure@eka_eoddb
                                where  corporate_id = pc_corporate_id and
                                       trade_date < pd_trade_date) and
                               trade_date <= pd_trade_date);
    commit;*/
    insert into eci_expired_ct_id
      (corporate_id, ct_id, trade_date, process_id, process)
      select corporate_id,
             ct_id,
             trade_date,
             process_id,
             process
        from eci_expired_ct_id@eka_eoddb eci
       where corporate_id = pc_corporate_id
         and trade_date = pd_trade_date
         and process = pc_process;
    commit;
    insert into edi_expired_dr_id
      (corporate_id, dr_id, trade_date, process_id, process)
      select corporate_id,
             dr_id,
             trade_date,
             process_id,
             process
        from edi_expired_dr_id@eka_eoddb edi
       where corporate_id = pc_corporate_id
         and trade_date = pd_trade_date
         and process = pc_process;
    commit;
  exception
    when others then
      null;
  end;

  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    Procedure Name                            : sp_mark_dumps_tatus
    Author                                    : Siva
    Created Date                              : 22th Mar 2010
    Purpose                                   : To updated DB dump status back to transaction schema
    
    Parameters
    pc_corporate_id                           : Corporate ID
    pd_trade_date                             : EOD Date ID
    pc_user_id                                : User ID
    pc_process                                : Process
    
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
  begin
    -- To update the DB Transfer complited status back to transaction schema
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'inside marking eod_dump_status as COMPLETED for pc_corporate_id ' ||
                          pc_corporate_id || '-pd_trade_date ' ||
                          pd_trade_date,
                          2);
    update eod_end_of_day_details
       set eod_dump_status = 'COMPLETED'
     where corporate_id = pc_corporate_id
       and as_of_date = pd_trade_date;
    --       and eod_dump_status <> 'COMPLETED';
    commit;
  exception
    when others then
      update eod_end_of_day_details
         set eod_dump_status = 'COMPLETED'
       where corporate_id = pc_corporate_id
         and as_of_date = pd_trade_date;
      commit;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            'Exception when others while marking eod_dump_status as COMPLETED',
                            2);
  end;
  procedure sp_mark_process_status(pc_corporate_id varchar2,
                                   pd_trade_date   date,
                                   pc_process      varchar2,
                                   pc_action       varchar2,
                                   pc_eod_status   varchar2) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    Procedure Name                            : sp_mark_dumps_tatus
    Author                                    : Siva
    Created Date                              : 22th Mar 2010
    Purpose                                   : To updated DB dump status back to transaction schema
    
    Parameters
    pc_corporate_id                           : Corporate ID
    pd_trade_date                             : EOD Date ID
    pc_user_id                                : User ID
    pc_process                                : Process
    
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
  begin
    -- To update the DB Transfer complited status back to transaction schema
    sp_eodeom_process_log(pc_corporate_id,
                          pd_trade_date,
                          'inside marking process_dump_status as COMPLETED for pc_corporate_id ' ||
                          pc_corporate_id || '-pd_trade_date ' ||
                          pd_trade_date,
                          2);
    --     pc_corporate_id, pd_trade_date  pc_process, pc_action ,pc_eod_status
    if pc_eod_status in ('EOD Processed Successfully',
        'EOD Process Success,Awaiting Cost Entry',
        'EOM Processed Successfully',
        'EOM Process Success,Awaiting Cost Entry') then
      insert into eod_eom_process_count
        (corporate_id,
         trade_date,
         process,
         created_date,
         processing_status)
      values
        (pc_corporate_id,
         pd_trade_date,
         pc_process,
         sysdate,
         pc_eod_status);
    end if;
    if pc_action in ('PRECHECK', 'PRECHECK_RUN', 'RUN') then
    
      if pc_process = 'EOD' then
        update eod_end_of_day_details
           set processing_status = pc_eod_status
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
        update eodh_end_of_day_history eodh
           set eodh.processing_status = pc_eod_status
         where eodh.eod_id in
               (select eod.eod_id
                  from eod_end_of_day_details eod
                 where eod.corporate_id = pc_corporate_id
                   and eod.as_of_date = pd_trade_date);
        commit;
      end if;
    else
      if pc_process = 'EOD' then
        update eodh_end_of_day_history eodh
           set eodh.processing_status = pc_eod_status
         where eodh.eod_id in
               (select eod.eod_id
                  from eod_end_of_day_details eod
                 where eod.corporate_id = pc_corporate_id
                   and eod.as_of_date = pd_trade_date
                   and (eod.processing_status like '%Running%' or
                       eod.processing_status like '%Cancelling%' or
                       eod.processing_status like '%Rolling%'));
        delete from eod_end_of_day_details eod
         where corporate_id = pc_corporate_id
           and as_of_date = pd_trade_date;
        commit;
      end if;
    end if;
  
  exception
    when others then
      update eod_end_of_day_details
         set processing_status = pc_eod_status
       where corporate_id = pc_corporate_id
         and as_of_date = pd_trade_date;
      update eodh_end_of_day_history eodh
         set eodh.processing_status = pc_eod_status
       where eodh.eod_id in
             (select eod.eod_id
                from eod_end_of_day_details eod
               where eod.corporate_id = pc_corporate_id
                 and eod.as_of_date = pd_trade_date);
      commit;
      sp_eodeom_process_log(pc_corporate_id,
                            pd_trade_date,
                            'Exception when others in sp_mark_process_status as' ||
                            pc_eod_status,
                            2);
  end;
  procedure sp_insert_eod_error_log(pc_corporate_id     varchar2,
                                    pc_submodule_name   varchar2,
                                    pc_exception_code   varchar2,
                                    pc_data_missing_for varchar2,
                                    pc_trade_ref_no     varchar2,
                                    pc_process          varchar2,
                                    pc_process_run_by   varchar2,
                                    pd_trade_date       date) is
    pragma autonomous_transaction;
  begin
    if pc_corporate_id is not null then
      insert into eel_eod_eom_exception_log@eka_eoddb
        (corporate_id,
         submodule_name,
         exception_code,
         data_missing_for,
         trade_ref_no,
         process,
         process_run_by,
         process_run_date,
         trade_date)
      values
        (pc_corporate_id,
         pc_submodule_name,
         pc_exception_code,
         pc_data_missing_for,
         pc_trade_ref_no,
         pc_process,
         pc_process_run_by,
         sysdate,
         pd_trade_date);
    end if;
    commit;
  exception
    when others then
      rollback;
  end;
  procedure sp_mark_process_count(pc_corporate_id varchar2,
                                  pc_process      varchar2,
                                  pd_trade_date   date) is
    pragma autonomous_transaction;
  begin
    if pc_corporate_id is not null then
      for cc in (select epc.corporate_id,
                        epc.trade_date,
                        epc.process,
                        count(*) process_count
                   from eod_eom_process_count epc
                  where epc.corporate_id = pc_corporate_id
                    and epc.process = pc_process
                    and epc.trade_date = pd_trade_date
                  group by epc.corporate_id,
                           epc.trade_date,
                           epc.process)
      loop
        update tdc_trade_date_closure@eka_eoddb tdc
           set tdc.process_run_count = cc.process_count
         where tdc.corporate_id = pc_corporate_id
           and tdc.trade_date = pd_trade_date
           and tdc.process = pc_process;
      end loop;
    end if;
    commit;
  exception
    when others then
      rollback;
  end;
  procedure sp_refresh_mv is
  
    /******************************************************************************************************************************************
    Procedure Name                            : sp_refresh_mv
    Author                                    : Siva
    Created Date                              : 29th Jul 2011
    Purpose                                   : To refresh mv available in app db schema
    
    Parameters
    
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
  begin
    dbms_mview.refresh('mv_dm_phy_open', 'C');
    dbms_mview.refresh('mv_dm_phy_stock', 'C');
    dbms_mview.refresh('mv_dm_phy_derivative', 'c');
    dbms_mview.refresh('mv_fact_phy_inv_valuation', 'c');
    dbms_mview.refresh('mv_fact_bm_phy_open_pnl', 'c');
    dbms_mview.refresh('mv_fact_bm_phy_stock_pnl', 'c');
    dbms_mview.refresh('mv_fact_derivative_realized', 'c');
    dbms_mview.refresh('mv_fact_derivative_unrealized', 'c');
    dbms_mview.refresh('MV_FACT_PHYSICAL_UNREALIZED', 'c');
    dbms_mview.refresh('MV_FACT_UNREALIZED', 'c');
    -------------------------------------------------------
    dbms_mview.refresh('MV_LATEST_EOD_DATES', 'c');
    dbms_mview.refresh('MV_TRPNL_CCY_BY_INSTRUMENT', 'c');
    dbms_mview.refresh('MV_TRPNL_DRT_BY_INSTRUMENT', 'c');
    dbms_mview.refresh('MV_TRPNL_NET_BY_PROFITCENTER', 'c');
    dbms_mview.refresh('MV_TRPNL_PHY_BY_PRODUCT', 'c');
    dbms_mview.refresh('MV_UNPNL_CCY_BY_INSTRUMENT', 'c');
    dbms_mview.refresh('MV_UNPNL_DRT_BY_INSTRUMENT', 'c');
    dbms_mview.refresh('MV_UNPNL_NET_BY_PROFITCENTER', 'c');
    dbms_mview.refresh('MV_UNPNL_PHY_BY_PRODUCT', 'c');
    dbms_mview.refresh('MV_UNPNL_PHY_CHANGE_BY_TRADE', 'c');
    dbms_mview.refresh('MV_BI_UPAD', 'c');
    dbms_mview.refresh('MV_FACT_BROKER_MARGIN_UTIL', 'c');
    ------------------------------------------------------------
  
    commit;
  exception
    when others then
      null;
      commit;
    
  end;
end;
/
create or replace package "PKG_EXECUTE_EOM" is

  procedure sp_execute_eom(pc_corporate_id       varchar2,
                           pc_action             varchar2,
                           pt_previous_pull_date timestamp,
                           pt_current_pull_date  timestamp,
                           pc_user_id            varchar2,
                           pd_trade_date         date,
                           pc_eom_status         out varchar2);

  procedure sp_record_cost(pc_corporate_id varchar2, pd_trade_date date);

  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date);

end pkg_execute_eom;
/
create or replace package body "PKG_EXECUTE_EOM" is

  procedure sp_execute_eom(pc_corporate_id       in varchar2,
                           pc_action             varchar2,
                           pt_previous_pull_date timestamp,
                           pt_current_pull_date  timestamp,
                           pc_user_id            varchar2,
                           pd_trade_date         date,
                           pc_eom_status         out varchar2) is
    vn_error_count            number;
    vn_error_only_error_count number;
    vc_process_status         varchar2(10) := 'NA';
  begin
    pkg_execute_process.sp_execute_process@eka_eoddb(pc_corporate_id,
                                                     pc_action,
                                                     'EOM',
                                                     pt_previous_pull_date,
                                                     pt_current_pull_date,
                                                     pc_user_id,
                                                     pd_trade_date);
    sp_mark_dumps_status(pc_corporate_id, pd_trade_date);
    begin
      select count(*)
        into vn_error_count
        from eel_eod_eom_exception_log@eka_eoddb eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = 'EOM'
         and nvl(eel.error_type, 'Error') = 'Error'
         and eel.trade_date = pd_trade_date;
      select count(*)
        into vn_error_only_error_count
        from eel_eod_eom_exception_log@eka_eoddb eel
       where eel.corporate_id = pc_corporate_id
         and eel.process = 'EOM'
         and eel.trade_date = pd_trade_date
         and nvl(eel.error_type, 'Error') = 'Error';
    exception
      when others then
        pc_eom_status := 'Code:' || sqlcode || 'Message:' || sqlerrm;
    end;
    if pc_action = 'PRECHECK' then
      if vn_error_count = 0 then
        pc_eom_status := 'Precheck Success, Run the EOM';
      else
        if vn_error_only_error_count > 0 then
          pc_eom_status := 'Precheck Completed, User input required';
        else
          pc_eom_status := 'Precheck Completed With Warnings';
        end if;
      end if;
    elsif pc_action = 'PRECHECK_RUN' then
      if vn_error_count = 0 then
        pc_eom_status := 'EOM Process Success,Awaiting Cost Entry';
        --Everything OK, Let us settle trades in Transaction Schema
        pkg_execute_eod.sp_record_expired_drid(pc_corporate_id,
                                               pd_trade_date,
                                               'EOM');
      else
        if vn_error_only_error_count > 0 then
          pc_eom_status := 'Precheck Completed, User input required';
        else
          pc_eom_status := 'Precheck Completed With Warnings';
        end if;
      end if;
    elsif pc_action = 'RUN' then
      if vn_error_count = 0 then
        pc_eom_status := 'EOM Process Success,Awaiting Cost Entry';
        --Everything OK, Let us settle trades in Transaction Schema
        pkg_execute_eod.sp_record_expired_drid(pc_corporate_id,
                                               pd_trade_date,
                                               'EOM');
      else
        pc_eom_status := 'EOM Process Failed';
      end if;
    end if;
    vc_process_status := pkg_process_status.sp_get@eka_eoddb(pc_corporate_id,
                                                             'EOM',
                                                             pd_trade_date);
    if vc_process_status = 'Cancel' then
      pc_eom_status := 'EOM Cancelled';
    end if;
    pkg_execute_eod.sp_mark_process_status(pc_corporate_id,
                                           pd_trade_date,
                                           'EOM',
                                           pc_action,
                                           pc_eom_status);
    pkg_execute_eod.sp_refresh_mv;
    if pc_eom_status in ('EOD Processed Successfully',
        'EOD Process Success,Awaiting Cost Entry',
        'EOM Processed Successfully',
        'EOM Process Success,Awaiting Cost Entry') then
      pkg_execute_eod.sp_mark_process_count(pc_corporate_id,
                                            'EOM',
                                            pd_trade_date);
    end if;
  end;

  procedure sp_record_cost(pc_corporate_id varchar2, pd_trade_date date) is
  begin
    pkg_execute_process.sp_record_misc_cost@eka_eoddb(pc_corporate_id,
                                                      pd_trade_date,
                                                      'EOM');
  end;

  procedure sp_mark_dumps_status(pc_corporate_id varchar2,
                                 pd_trade_date   date) is
    pragma autonomous_transaction;
    /******************************************************************************************************************************************
    Procedure Name                            : sp_mark_dumps_tatus
    Author                                    : Siva
    Created Date                              : 22th Mar 2010
    Purpose                                   : To updated DB dump status back to transaction schema
    
    Parameters
    pc_corporate_id                           : Corporate ID
    pd_trade_date                             : EOD Date ID
    pc_user_id                                : User ID
    pc_process                                : Process
    
    Modification History
    Modified Date                             :
    Modified By                               :
    Modify Description                        :
    ******************************************************************************************************************************************/
  begin
    -- To update the DB Transfer complited status back to transaction schema
    update eom_end_of_month_details
       set eom_dump_status = 'COMPLETED'
     where corporate_id = pc_corporate_id
       and as_of_date = pd_trade_date
       and eom_dump_status <> 'COMPLETED';
    commit;
  exception
    when others then
      null;
  end;

end;
/

delete from ref_reportexportformat ref where ref.report_id = 257;
delete from rpc_rf_parameter_config rpc where rpc.report_id = 257;
delete from rfc_report_filter_config rfc where rfc.report_id = 257;
delete from amc_app_menu_configuration amc where amc.menu_id = 'RPT-D257';
delete from rml_report_master_list rml where rml.report_id = 257;
SET DEFINE OFF;
Insert into RML_REPORT_MASTER_LIST
   (REPORT_ID, SECTION_ID, REPORT_FILE_NAME, REPORT_DISPLAY_NAME, FEATURE_ID, 
    REPORT_DISPLAY_NAME_DE, REPORT_DISPLAY_NAME_ES, ACTION_METHOD, REPORT_TYPE, IS_ACTIVE)
 Values
   ('257', '31', 'MonthlyClosingBalanceReport.rpt', 'Monthly Closing Balance Report', NULL, 
    NULL, NULL, 'populateFilter', 'EOM', 'Y');
Insert into REF_REPORTEXPORTFORMAT
   (REPORT_ID, EXPORT_FORMAT, REPORT_FILE_NAME)
 Values
   ('257', 'EXCEL', 'MonthlyClosingBalanceReport.rpt');
Insert into AMC_APP_MENU_CONFIGURATION
   (MENU_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, LINK_CALLED, 
    ICON_CLASS, MENU_PARENT_ID, ACL_ID, TAB_ID, FEATURE_ID, 
    IS_DELETED)
 Values
   ('RPT-D257', 'Monthly Closing Balance Report', 24, 5, '/EkaReport/CommonFilter.do?method=populateFilter&docType=EOM&ReportID=257&ReportName=MonthlyClosingBalanceReport.rpt&ExportFormat=HTML&isEodReport=Y', 
    NULL, 'RPT-D23', NULL, 'Reports', NULL, 
    'N');
COMMIT;


SET DEFINE OFF;
declare
begin
 for cc in (select *
               from ak_corporate akc
              where akc.is_internal_corporate = 'N')
loop
    dbms_output.put_line(cc.corporate_id);
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 1, 3, 
    'Smelter', 'GFF1001', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 1, 1, 
    'Year', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 1, 5, 
    'Report Type', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 1, 6, 
    'Product', 'GFF1011', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY06', 1, 7, 
    'Quality', 'GFF1011', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 1, 2, 
    'Month', 'GFF1012', 1, 'Y');
Insert into RFC_REPORT_FILTER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, 
    LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
 Values
   (cc.corporate_id, '257', 'RFC257PHY08', 1, 4, 
    'Report Data', 'GFF1012', 1, 'Y');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1045', 'quality');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1046', 'Quality');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1050', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY06', 'RFP1051', 'multiple');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1001', 'businesspartner');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1002', 'Arrival');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1003', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1004', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1005', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1006', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY03', 'RFP1008', 'WAREHOUSING');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1060', 'ReportDataList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY08', 'RFP1061', 'ReportData');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1060', 'MonthList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1061', 'Month');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY02', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1060', 'yearList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY01', 'RFP1061', 'Year');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1060', 'reportList');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1062', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1063', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1064', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1065', '1');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1066', 'Yes');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY04', 'RFP1061', 'ReportType');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1045', 'allProducts');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1046', 'Product');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1047', 'No');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1048', 'Filter');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1049', 'reportForm');
Insert into RPC_RF_PARAMETER_CONFIG
   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
 Values
   (cc.corporate_id, '257', 'RFC257PHY05', 'RFP1050', '1');
COMMIT;
  end loop;
commit;
end;
Update  PLD_PRODUCT_LICENCE_DETAIL SET PRODUCT_VERSION ='8.1.17.0';
commit;