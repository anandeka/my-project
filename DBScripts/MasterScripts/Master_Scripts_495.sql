DECLARE
   fetchqrybm     CLOB
      := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, DESCRIPTION, internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no
                                                   AS internal_invoice_ref_no,
                         NVL
                            (pcmac.addn_charge_name,
                             scm.cost_display_name
                            ) AS other_charge_cost_name,
                         ioc.charge_type AS charge_type,
                         (CASE
                             WHEN (ioc.rate_fx_rate IS NULL)
                             AND (ioc.flat_amount_fx_rate IS NULL)
                                THEN 1
                             WHEN ioc.rate_fx_rate IS NULL
                                THEN ioc.flat_amount_fx_rate
                             ELSE ioc.rate_fx_rate
                          END
                         ) AS fx_rate,
                         ioc.quantity AS quantity,
                         NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                         ioc.amount_in_inv_cur AS invoice_amount,
                         cm.cur_code AS invoice_cur_name,
                         (CASE
                             WHEN ioc.rate_price_unit = ''Bags''
                             AND ioc.charge_type = ''Rate''
                                THEN cm.cur_code || ''/'' || ''Bag''
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                                     ''Ocular Inspection Charge'')
                             AND ioc.charge_type = ''Rate''
                                THEN cm_lot.cur_code || ''/'' || ''Lot''
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
                                    (''Assay Charge'', ''Sampling Charge'',
                                     ''Ocular Inspection Charge'')
                                THEN ''Lots''
                             WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                                THEN ''Lots''
                             ELSE qum.qty_unit
                          END
                         ) AS quantity_unit,
                         (CASE
                             WHEN scm.cost_component_name IN
                                    (''Assay Charge'', ''Sampling Charge'',
                                     ''Ocular Inspection Charge'')
                             AND ioc.charge_type = ''Rate''
                                THEN cm_lot.cur_code
                             WHEN scm.cost_component_name IN
                                                          (''Handling Charge'')
                                THEN cm.cur_code
                             WHEN ioc.charge_type =''Rate''
                                THEN cm_pum.cur_code
                             ELSE cm_ioc.cur_code
                          END
                         ) AS amount_unit,
                         IOC.OTHER_CHARGE_DESC as DESCRIPTION,
                         ?
                    FROM is_invoice_summary invs,
                         ioc_invoice_other_charge ioc,
                         cm_currency_master cm,
                         scm_service_charge_master scm,
                         ppu_product_price_units ppu,
                         pum_price_unit_master pum,
                         qum_quantity_unit_master qum,
                         cm_currency_master cm_ioc,
                         cm_currency_master cm_pum,
                         cm_currency_master cm_lot,
                         pcmac_pcm_addn_charges pcmac
                   WHERE invs.internal_invoice_ref_no =
                                                   ioc.internal_invoice_ref_no
                     AND ioc.other_charge_cost_id = scm.cost_id(+)
                     AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
                     AND ioc.invoice_cur_id = cm.cur_id(+)
                     AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
                     AND ioc.rate_price_unit = cm_lot.cur_id(+)
                     AND ppu.price_unit_id = pum.price_unit_id(+)
                     AND ioc.qty_unit_id = qum.qty_unit_id(+)
                     AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
                     AND cm_pum.cur_id(+) = pum.cur_id
                     AND ioc.internal_invoice_ref_no = ?)
   SELECT *
     FROM TEST t
    WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
   fetchqryconc   CLOB
      := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, quantity_unit,
             amount_unit, DESCRIPTION, internal_doc_ref_no)
WITH TEST AS
     (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                      NVL (pcmac.addn_charge_name,
                           scm.cost_display_name
                          ) AS other_charge_cost_name,
                      ioc.charge_type AS charge_type,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          WHEN (ioc.rate_fx_rate IS NULL)
                          AND (ioc.flat_amount_fx_rate IS NULL)
                             THEN 1
                          WHEN ioc.rate_fx_rate IS NULL
                             THEN ioc.flat_amount_fx_rate
                          ELSE ioc.rate_fx_rate
                       END
                      ) AS fx_rate,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE ioc.quantity
                       END
                      ) AS quantity,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE NVL (ioc.rate_amount, ioc.flat_amount)
                       END
                      ) AS amount,
                      ioc.amount_in_inv_cur AS invoice_amount,
                      cm.cur_code AS invoice_cur_name,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          WHEN ioc.rate_price_unit = ''Bags''
                          AND ioc.charge_type = ''Rate''
                             THEN cm.cur_code || ''/'' || ''Bag''
                          WHEN scm.cost_component_name IN
                                 (''Assay Charge'', ''Sampling Charge'',
                                  ''Ocular Inspection Charge'')
                          AND ioc.charge_type = ''Rate''
                             THEN cm_lot.cur_code || ''/'' || ''Lot''
                          ELSE pum.price_unit_name
                       END
                      ) AS rate_price_unit_name,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE NVL (ioc.flat_amount,ioc.rate_charge)
                       END
                      ) AS charge_amount_rate,
                      (CASE
                          WHEN ioc.rate_price_unit = ''Bags''
                             THEN ''Bags''
                          WHEN scm.cost_component_name IN
                                 (''Assay Charge'', ''Sampling Charge'',
                                  ''Ocular Inspection Charge'')
                             THEN ''Lots''
                          WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                             THEN ''Lots''
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          ELSE qum.qty_unit
                       END
                      ) AS quantity_unit,
                      (CASE
                          WHEN (scm.cost_display_name = ''Location Value'')
                             THEN NULL
                          WHEN scm.cost_component_name IN
                                 (''Assay Charge'',''Sampling Charge'',
                                  ''Ocular Inspection Charge'')
                          AND ioc.charge_type = ''Rate''
                             THEN cm_lot.cur_code
                          WHEN scm.cost_component_name IN (''Handling Charge'')
                             THEN cm.cur_code
                          WHEN ioc.charge_type = ''Rate''
                             THEN cm_pum.cur_code
                          ELSE cm_ioc.cur_code
                       END
                      ) AS amount_unit,
                      IOC.OTHER_CHARGE_DESC as DESCRIPTION,
                      ?
                 FROM is_invoice_summary invs,
                      ioc_invoice_other_charge ioc,
                      cm_currency_master cm,
                      scm_service_charge_master scm,
                      ppu_product_price_units ppu,
                      pum_price_unit_master pum,
                      qum_quantity_unit_master qum,
                      cm_currency_master cm_ioc,
                      cm_currency_master cm_pum,
                      cm_currency_master cm_lot,
                      pcmac_pcm_addn_charges pcmac
                WHERE invs.internal_invoice_ref_no =
                                                   ioc.internal_invoice_ref_no
                  AND ioc.other_charge_cost_id = scm.cost_id(+)
                  AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
                  AND ioc.invoice_cur_id = cm.cur_id(+)
                  AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
                  AND ioc.rate_price_unit = cm_lot.cur_id(+)
                  AND ppu.price_unit_id = pum.price_unit_id(+)
                  AND ioc.qty_unit_id = qum.qty_unit_id(+)
                  AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
                  AND cm_pum.cur_id(+) = pum.cur_id
                  AND ioc.internal_invoice_ref_no = ?)
SELECT *
  FROM TEST t
 WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
   fetchqryoci    CLOB
      := 'INSERT INTO ioc_d
            (internal_invoice_ref_no, other_charge_cost_name, charge_type,
             fx_rate, quantity, amount, invoice_amount, invoice_cur_name,
             rate_price_unit_name, charge_amount_rate, description, quantity_unit,
             amount_unit, DESCRIPTION, internal_doc_ref_no)
   WITH TEST AS
        (SELECT DISTINCT invs.internal_invoice_ref_no AS internal_invoice_ref_no,
                (CASE
                    WHEN (pcmac.addn_charge_name IS NULL)
                    AND (scm.cost_display_name IS NULL)
                       THEN mcc.charge_name
                    WHEN pcmac.addn_charge_name IS NULL
                       THEN scm.cost_display_name
                    ELSE pcmac.addn_charge_name
                 END
                ) AS other_charge_cost_name,
                ioc.charge_type AS charge_type,
                (CASE
                    WHEN (ioc.rate_fx_rate IS NULL)
                    AND (ioc.flat_amount_fx_rate IS NULL)
                       THEN 1
                    WHEN ioc.rate_fx_rate IS NULL
                       THEN ioc.flat_amount_fx_rate
                    ELSE ioc.rate_fx_rate
                 END
                ) AS fx_rate,
                ioc.quantity AS quantity,
                NVL (ioc.rate_amount, ioc.flat_amount) AS amount,
                ioc.amount_in_inv_cur AS invoice_amount,
                cm.cur_code AS invoice_cur_name,
                (CASE
                    WHEN ioc.rate_price_unit = ''Bags''
                    AND ioc.charge_type = ''Rate''
                       THEN cm.cur_code || ''/'' || ''Bag''
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                    AND ioc.charge_type = ''Rate''
                       THEN cm_lot.cur_code || ''/'' || ''Lot''
                    ELSE pum.price_unit_name
                 END
                ) AS rate_price_unit_name,
                NVL (ioc.flat_amount, ioc.rate_charge) AS charge_amount_rate,
                NVL (ioc.other_charge_desc,
                     aml.attribute_name) AS description,
                (CASE
                    WHEN ioc.rate_price_unit = ''Bags''
                       THEN ''Bags''
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                       THEN ''Lots''
                    WHEN scm.cost_component_name IN
                                            (''AssayCharge'', ''SamplingCharge'')
                       THEN ''Lots''
                    ELSE qum.qty_unit
                 END
                ) AS quantity_unit,
                (CASE
                    WHEN scm.cost_component_name IN
                           (''Assay Charge'', ''Sampling Charge'',
                            ''Ocular Inspection Charge'')
                    AND ioc.charge_type = ''Rate''
                       THEN cm_lot.cur_code
                    WHEN scm.cost_component_name IN (''Handling Charge'')
                       THEN cm.cur_code
                    WHEN ioc.charge_type = ''Rate''
                       THEN cm_pum.cur_code
                    ELSE cm_ioc.cur_code
                 END
                ) AS amount_unit,
                IOC.OTHER_CHARGE_DESC as DESCRIPTION,
                ?
           FROM is_invoice_summary invs,
                ioc_invoice_other_charge ioc,
                cm_currency_master cm,
                scm_service_charge_master scm,
                ppu_product_price_units ppu,
                pum_price_unit_master pum,
                qum_quantity_unit_master qum,
                cm_currency_master cm_ioc,
                cm_currency_master cm_pum,
                cm_currency_master cm_lot,
                pcmac_pcm_addn_charges pcmac,
                mcc_miscellaneous_comm_charges mcc,
                aml_attribute_master_list aml
          WHERE invs.internal_invoice_ref_no = ioc.internal_invoice_ref_no
            AND ioc.other_charge_cost_id = scm.cost_id(+)
            AND ioc.other_charge_cost_id = pcmac.addn_charge_id(+)
            AND ioc.other_charge_cost_id IN (
                   SELECT mcc.mcc_id
                     FROM mcc_miscellaneous_comm_charges mcc
                   UNION ALL
                   SELECT mcc.charge_id
                     FROM mcc_miscellaneous_comm_charges mcc)
            AND mcc.element_id = aml.attribute_id(+)
            AND ioc.invoice_cur_id = cm.cur_id(+)
            AND ioc.rate_price_unit = ppu.internal_price_unit_id(+)
            AND ioc.rate_price_unit = cm_lot.cur_id(+)
            AND ppu.price_unit_id = pum.price_unit_id(+)
            AND ioc.qty_unit_id = qum.qty_unit_id(+)
            AND ioc.flat_amount_cur_unit_id = cm_ioc.cur_id(+)
            AND cm_pum.cur_id(+) = pum.cur_id
            AND ioc.internal_invoice_ref_no = ?)
   SELECT *
     FROM TEST t
    WHERE t.other_charge_cost_name NOT IN (''Freight Allowance'')';
   fetchqrypfi    CLOB
      := 'INSERT into IOC_D (
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
    select distinct
    INVS.INTERNAL_INVOICE_REF_NO as INTERNAL_INVOICE_REF_NO,
    nvl(PCMAC.ADDN_CHARGE_NAME, SCM.COST_DISPLAY_NAME) as OTHER_CHARGE_COST_NAME,
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
    CM_CURRENCY_MASTER cm_ioc,
    PCMAC_PCM_ADDN_CHARGES pcmac
    where
    INVS.INTERNAL_INVOICE_REF_NO = IOC.INTERNAL_INVOICE_REF_NO
    and IOC.OTHER_CHARGE_COST_ID = SCM.COST_ID(+)
    and IOC.OTHER_CHARGE_COST_ID = PCMAC.ADDN_CHARGE_ID(+)
    and IOC.INVOICE_CUR_ID = CM.CUR_ID(+)
    and IOC.RATE_PRICE_UNIT = PPU.INTERNAL_PRICE_UNIT_ID(+)
    and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
    and IOC.QTY_UNIT_ID = QUM.QTY_UNIT_ID(+)
    and IOC.FLAT_AMOUNT_CUR_UNIT_ID = CM_IOC.CUR_ID(+)
    and IOC.INTERNAL_INVOICE_REF_NO = ?';

fetchqrydc clob := 'INSERT into IOC_D (
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
    
BEGIN

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqrybm
    WHERE dgm.doc_id IN ('CREATE_DFI', 'CREATE_FI', 'CREATE_PI')
      AND dgm.is_concentrate = 'N'
      AND dgm.dgm_id IN ('DGM-IOC_BM', 'DGM-DFI-C7');

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryconc
    WHERE dgm.doc_id IN ('CREATE_DFI', 'CREATE_FI', 'CREATE_PI')
      AND dgm.is_concentrate = 'Y'
      AND dgm.dgm_id IN ('DGM-IOC_C');

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqrypfi
    WHERE dgm.doc_id IN ('CREATE_PFI', 'CREATE_API')
      AND dgm.dgm_id IN
               ('DGM-PFI-6-CONC', 'DGM-PFI-6', 'DGM-API-5-CONC', 'DGM-API-5');

   UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqryoci
    WHERE dgm.doc_id IN ('CREATE_OCI') AND dgm.dgm_id IN ('DGM_OCI_IOC');
    
    UPDATE dgm_document_generation_master dgm
      SET dgm.fetch_query = fetchqrydc
    WHERE dgm.doc_id IN ('CREATE_DC') AND dgm.dgm_id IN ('DGM-IOC_BM');
commit;
END;