DELETE FROM dgm_document_generation_master dgm
      WHERE dgm.dgm_id IN ('DGM-DC-C1', 'DGM-IOC_BM', 'DGM-ITD_BM')
        AND dgm.doc_id = 'CREATE_DC'
        AND dgm.sequence_order IN (2, 3, 4);

COMMIT;

declare fetchQuerydcChildBM CLOB := 'INSERT INTO IS_DC_CHILD_D(
INTERNAL_INVOICE_REF_NO,
DESCRIPTION,
INVOICED_WEIGHT,
NEW_INVOICED_WEIGHT,
INVOICE_PRICE,
NEW_INVOICE_PRICE,
AMOUNT,
NEW_AMOUNT,
OLD_INVOICE_AMOUNT,
NEW_INVOICE_AMOUNT,
NET_ADJUSTMENT,
OLD_PRICE_UNIT_NAME,
NEW_PRICE_UNIT_NAME,
OLD_INVOICE_CUR_UNIT,
NEW_INVOICE_CUR_UNIT,
INVOICE_CUR_UNIT,
INVOICE_QTY_UNIT_NAME,
INTERNAL_DOC_REF_NO
)
select
IID.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
GMR.GMR_REF_NO as DESCRIPTION,
IID.INVOICED_QTY as INVOICED_WEIGHT,
IID.NEW_INVOICED_QTY as NEW_INVOICED_WEIGHT,
IID.INVOICED_PRICE as INVOICE_PRICE,
IID.NEW_INVOICE_PRICE as NEW_INVOICE_PRICE,
IID.ITEM_AMOUNT as AMOUNT,
IID.INVOICE_ITEM_AMOUNT as NEW_AMOUNT,
IID.ITEM_AMOUNT as OLD_INVOICE_AMOUNT,
(IID.NEW_INVOICED_QTY * IID.NEW_INVOICE_PRICE) as NEW_INVOICE_AMOUNT,
(IID.INVOICE_ITEM_AMOUNT - IID.ITEM_AMOUNT) as NET_ADJUSTMENT,
PUM.PRICE_UNIT_NAME as OLD_PRICE_UNIT_NAME,
PUM.PRICE_UNIT_NAME as NEW_PRICE_UNIT_NAME,
CM.CUR_CODE as OLD_INVOICE_CUR_UNIT,
CM.CUR_CODE as NEW_INVOICE_CUR_UNIT,
CM.CUR_CODE as INVOICE_CUR_UNIT,
QUM.QTY_UNIT as INVOICE_QTY_UNIT_NAME,
?
from
IS_INVOICE_SUMMARY invs,
IID_INVOICABLE_ITEM_DETAILS iid,
QUM_QUANTITY_UNIT_MASTER qum,
CM_CURRENCY_MASTER cm,
PPU_PRODUCT_PRICE_UNITS ppu,
PUM_PRICE_UNIT_MASTER pum,
GMR_GOODS_MOVEMENT_RECORD gmr
where
INVS.INTERNAL_INVOICE_REF_NO = IID.INTERNAL_INVOICE_REF_NO
and IID.INVOICE_CURRENCY_ID = CM.CUR_ID
and IID.INVOICED_PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID
and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
and IID.INVOICED_QTY_UNIT_ID = QUM.QTY_UNIT_ID
and IID.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO
and INVS.INTERNAL_INVOICE_REF_NO = ?';


fetchQueryIOCDCBM CLOB := 'INSERT into IOC_D (
    INTERNAL_INVOICE_REF_NO,
    OTHER_CHARGE_COST_NAME,
    CHARGE_TYPE,
    FX_RATE,
    QUANTITY,
    AMOUNT,
    INVOICE_AMOUNT,
    INVOICE_CUR_NAME,
    RATE_PRICE_UNIT_NAME,
    CHARGE_AMOUNT_RATE,
    QUANTITY_UNIT,
    AMOUNT_UNIT,
    DESCRIPTION,
    INTERNAL_DOC_REF_NO
    )
    select 
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    SCM.COST_DISPLAY_NAME as OTHER_CHARGE_COST_NAME,
    IOC.CHARGE_TYPE as CHARGE_TYPE,
    nvl(IOC.RATE_FX_RATE, IOC.FLAT_AMOUNT_FX_RATE) as FX_RATE,
    IOC.QUANTITY as QUANTITY,
    nvl(IOC.RATE_AMOUNT, IOC.FLAT_AMOUNT) as AMOUNT,
    IOC.AMOUNT_IN_INV_CUR as INVOICE_AMOUNT,
    CM.CUR_CODE as INVOICE_CUR_NAME,
    PUM.PRICE_UNIT_NAME as RATE_PRICE_UNIT_NAME,
    nvl(IOC.FLAT_AMOUNT, IOC.RATE_CHARGE) as CHARGE_AMOUNT_RATE,
    QUM.QTY_UNIT as QUANTITY_UNIT,
    CM_IOC.CUR_CODE as AMOUNT_UNIT,
    IOC.OTHER_CHARGE_DESC as DESCRIPTION,
    ?
    from
    IS_INVOICE_SUMMARY invs,
    IOC_INVOICE_OTHER_CHARGE ioc,
    CM_CURRENCY_MASTER cm,
    SCM_SERVICE_CHARGE_MASTER scm,
    PPU_PRODUCT_PRICE_UNITS ppu,
    PUM_PRICE_UNIT_MASTER pum,
    QUM_QUANTITY_UNIT_MASTER qum,
    CM_CURRENCY_MASTER cm_ioc
    where
    INVS.INTERNAL_INVOICE_REF_NO = IOC.INTERNAL_INVOICE_REF_NO
    and IOC.OTHER_CHARGE_COST_ID = SCM.COST_ID
    and IOC.INVOICE_CUR_ID = CM.CUR_ID
    and IOC.RATE_PRICE_UNIT = PPU.INTERNAL_PRICE_UNIT_ID(+)
    and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
    and IOC.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
    and IOC.FLAT_AMOUNT_CUR_UNIT_ID = CM_IOC.CUR_ID(+)
    and IOC.INTERNAL_INVOICE_REF_NO = ?';
      


fetchQueryITDDCBM CLOB := 'INSERT INTO itd_d
            (internal_invoice_ref_no, tax_code, tax_rate, invoice_currency,
             fx_rate, amount, tax_currency, invoice_amount, applicable_on,
             internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          tm.tax_code AS tax_code, itd.tax_rate AS tax_rate,
          cm.cur_code AS invoice_currency, itd.fx_rate AS fx_rate,
          itd.tax_amount AS amount, cm_tax.cur_code AS tax_currency,
          itd.tax_amount_in_inv_cur AS invoice_amount,
          itd.applicable_on AS applicable_on, ?
     FROM is_invoice_summary invs,
          itd_invoice_tax_details itd,
          tm_tax_master tm,
          cm_currency_master cm,
          cm_currency_master cm_tax
    WHERE invs.internal_invoice_ref_no = itd.internal_invoice_ref_no
      AND itd.tax_code_id = tm.tax_id
      AND itd.invoice_cur_id = cm.cur_id
      AND itd.tax_amount_cur_id = cm_tax.cur_id
      AND itd.internal_invoice_ref_no = ?';


fetchQuerybdsDCBM CLOB := 'INSERT INTO is_bds_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction,remarks,internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          oipi.beneficiary_name AS beneficiary_name,
          phd.companyname AS bank_name, oipi.bank_account AS account_no,
          oipi.aba_no AS aba_rtn, oipi.instructions AS instruction, OIPI.REMARKS as remarks, ?
     FROM phd_profileheaderdetails phd,
          oba_our_bank_accounts oba,
          is_invoice_summary invs,
          oipi_our_inv_pay_instruction oipi  
    WHERE invs.internal_invoice_ref_no = oipi.internal_invoice_ref_no
      AND oba.bank_id = phd.profileid
      AND oba.bank_id = oipi.bank_id
      and OIPI.BANK_ACCOUNT_ID = OBA.ACCOUNT_ID
      AND invs.internal_invoice_ref_no = ?';


fetchQuerybdpDCBM CLOB := 'INSERT INTO is_bdp_child_d
            (internal_invoice_ref_no, beneficiary_name, bank_name, account_no,
             aba_rtn, instruction, remarks, iban, internal_doc_ref_no)
   SELECT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
          cpipi.beneficiary_name AS beneficiary_name,
          bpb.bank_name AS bank_name, bpa.account_no AS account_no,
          cpipi.aba_no AS aba_rtn, cpipi.instructions AS instruction,
          cpipi.remarks AS remarks, bpa.iban AS iban, ?
     FROM bpa_bp_bank_accounts bpa,
          bpb_business_partner_banks bpb,
          is_invoice_summary invs,
          cpipi_cp_inv_pay_instruction cpipi
    WHERE invs.internal_invoice_ref_no = cpipi.internal_invoice_ref_no
      AND cpipi.bank_id = bpa.bank_id
      AND bpa.bank_id = bpb.bank_id
      AND cpipi.bank_account_id = bpa.account_id
      AND invs.internal_invoice_ref_no = ?';


begin
INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-DC-C1','CREATE_DC','Debit Credit','CREATE_DC',2,fetchQuerydcChildBM,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-IOC_BM','CREATE_DC','Debit Credit','CREATE_DC',3,fetchQueryIOCDCBM,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-ITD_BM','CREATE_DC','Debit Credit','CREATE_DC',4,fetchQueryITDDCBM,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-BDS-DC_BM','CREATE_DC','Debit Credit','CREATE_DC',5,fetchQuerybdsDCBM,'N');

INSERT INTO DGM_DOCUMENT_GENERATION_MASTER(DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, FETCH_QUERY, IS_CONCENTRATE) VALUES('DGM-BDP-DC_BM','CREATE_DC','Debit Credit','CREATE_DC',6,fetchQuerybdpDCBM,'N');
commit;
end;