
DECLARE
   fetchAPIDetailsForDFT   CLOB
      := 'INSERT INTO API_DETAILS_D(
INTERNAL_INVOICE_REF_NO,
API_INVOICE_REF_NO,
API_AMOUNT_ADJUSTED,
INVOICE_CURRENCY,
INTERNAL_DOC_REF_NO
)
select
INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
INVS_API.INVOICE_REF_NO as API_INVOICE_REF_NO,
CIAPM.API_AMOUNT_ADJUSTED as API_AMOUNT_ADJUSTED,
CM.CUR_CODE as INVOICE_CURRENCY,
?
from
IS_INVOICE_SUMMARY invs,
IS_INVOICE_SUMMARY invs_api,
CIAPM_COMM_INV_ADV_PAY_MAPPING ciapm,
CM_CURRENCY_MASTER cm
where
CIAPM.INTERNAL_INVOICE_REF_NO = INVS.INTERNAL_INVOICE_REF_NO
and CIAPM.API_INTERNAL_INVOICE_REF_NO = INVS_API.INTERNAL_INVOICE_REF_NO
and INVS_API.INVOICE_CUR_ID = CM.CUR_ID
and INVS.INTERNAL_INVOICE_REF_NO = ?';

fetchIEPDDetailsForDFT   CLOB
      := 'INSERT INTO IEPD_D(
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
    and IEPD.INTERNAL_INVOICE_REF_NO = ?';

fetchIEFPDDetailsForDFT   CLOB
      := 'INSERT INTO IEFPD_D(
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
    AND IEFPD.INTERNAL_INVOICE_REF_NO = ?';

fetchIGDDetailsForDFT   CLOB
      := 'INSERT INTO igd_inv_gmr_details_d
            (internal_invoice_ref_no, gmr_ref_no, container_name,
             mode_of_transport, bl_date, origin_city, origin_country, wet_qty,
             wet_qty_unit_name, internal_doc_ref_no)
SELECT   invs.internal_invoice_ref_no AS internal_invoice_ref_no,
         gmr.gmr_ref_no AS gmr_ref_no,
         (SELECT stragg (DISTINCT agrd.container_no)
            FROM agrd_action_grd agrd
           WHERE agrd.internal_gmr_ref_no =
                                    gmr.internal_gmr_ref_no)
                                                            AS container_name,
         NVL (gmr.mode_of_transport, '''') AS mode_of_transport,
         gmr.bl_date AS bl_date, NVL (cim.city_name, '''') AS origin_city,
         NVL (cym.country_name, '''') AS origin_country, gmr.current_qty AS wet_qty,
         qum.qty_unit AS wet_qty_unit_name, ?
    FROM is_invoice_summary invs,
         iid_invoicable_item_details iid,
         grd_goods_record_detail grd,
         dgrd_delivered_grd dgrd,
         gmr_goods_movement_record gmr,
         cym_countrymaster cym,
         cim_citymaster cim,
         qum_quantity_unit_master qum
   WHERE iid.internal_invoice_ref_no = invs.internal_invoice_ref_no
     AND iid.internal_gmr_ref_no = gmr.internal_gmr_ref_no
     AND iid.stock_id = grd.internal_grd_ref_no(+)
     AND iid.stock_id = dgrd.internal_dgrd_ref_no(+)
     AND invs.invoiced_qty_unit_id = qum.qty_unit_id
     AND cym.country_id(+) = gmr.loading_country_id
     AND cim.city_id(+) = gmr.loading_city_id
     AND invs.internal_invoice_ref_no = ?
GROUP BY gmr.internal_gmr_ref_no,
         gmr.current_qty,
         invs.internal_invoice_ref_no,
         grd.container_no,
         gmr.mode_of_transport,
         gmr.bl_date,
         gmr.gmr_ref_no,
         cym.country_name,
         cim.city_name,
         qum.qty_unit';


BEGIN

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-DFI-C8', 'CREATE_DFT_DFI', 'Draft Direct Final Invoice', 'CREATE_DFT_DFI', 8, fetchAPIDetailsForDFT, 'N');

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-FI-C8', 'CREATE_DFT_FI', 'Draft Final Invoice', 'CREATE_DFT_FI', 8, fetchAPIDetailsForDFT, 'N');

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-DFI-C9', 'CREATE_DFT_DFI', 'Draft Direct Final Invoice', 'CREATE_DFT_DFI', 9, fetchIEPDDetailsForDFT, 'N');

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-FI-C9', 'CREATE_DFT_FI', 'Draft Final Invoice', 'CREATE_DFT_FI', 9, fetchIEPDDetailsForDFT, 'N');

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-DFI-C10', 'CREATE_DFT_DFI', 'Draft Direct Final Invoice', 'CREATE_DFT_DFI', 10, fetchIEFPDDetailsForDFT, 'N');

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-FI-C10', 'CREATE_DFT_FI', 'Draft Final Invoice', 'CREATE_DFT_FI', 10, fetchIEFPDDetailsForDFT, 'N');

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-PI-C9', 'CREATE_DFT_PI', 'Draft Provisional Invoice', 'CREATE_DFT_PI', 9, fetchIGDDetailsForDFT, 'N');

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-DFI-C11', 'CREATE_DFT_DFI', 'Draft Direct Final Invoice', 'CREATE_DFT_DFI', 11, fetchIGDDetailsForDFT, 'N');

    INSERT INTO dgm_document_generation_master VALUES ('DGM-DFT-FI-C11', 'CREATE_DFT_FI', 'Draft Final Invoice', 'CREATE_DFT_FI', 11, fetchIGDDetailsForDFT, 'N');

   COMMIT;
END;