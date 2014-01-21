CREATE OR REPLACE FUNCTION GETDELIVERYPERIODDETAILS(p_contractNo  VARCHAR2,
                                                    p_delivery_id VARCHAR2, istollingcontract VARCHAR2,
                                                    product_group_type VARCHAR2)
  return CLOB is
  deliveryDescription CLOB := '';
  --deliveryItem        VARCHAR2(4000) := '';
  quotaPeriod         VARCHAR2(4000) := '';
  qualityDetails      VARCHAR2(4000) := '';
  quantityDetails     VARCHAR2(4000) := '';
  incotermDetails     VARCHAR2(4000) := 'Terms of Delivery:';
  pricingDetails      VARCHAR2(4000) := 'Pricing of Payable metals :';
  formulaDetails      VARCHAR2(4000) := '';
  QPDeclarationDate   VARCHAR2(50);
  PaymentDueDate      VARCHAR2(50);
  Optionality         VARCHAR2(50);
  minQtyOp            VARCHAR2(15);
  maxQtyOp            VARCHAR2(15);
  minQtyValue         NUMBER(25, 10);
  maxQtyValue         NUMBER(25, 10);
  itemQtyUnit         VARCHAR2(50);
  packingtype         VARCHAR2 (4000) := '';
  payableContent      VARCHAR2(4000) := '';
  pcDetails           VARCHAR2(4000) := '';
  returnableContent   VARCHAR2(4000) := '';
  returnableDetails   VARCHAR2(4000) := '';
  treatmentCharge     VARCHAR2(4000) := '';
  tcDetails           VARCHAR2(4000) := 'Treatment Charges: ';
  refiningCharge      VARCHAR2(4000) := '';
  rcDetails           VARCHAR2(4000) := 'Refining Charges: ';

  cursor cr_incoterm IS
    Select 'Incoterm ' || ITM.INCOTERM || ' - ' || CIM.CITY_NAME || (case
             WHEN PCDB.CUSTOMS IS Null THEN
              ''
             ELSE
              ' ,Custom ' || PCDB.CUSTOMS
           END) || (case
             WHEN PCDB.DUTY_STATUS IS Null THEN
              ''
             ELSE
              ' ,Duty ' || PCDB.DUTY_STATUS
           END) || (case
             WHEN PCDB.TAX_STATUS IS Null THEN
              ''
             ELSE
              ' ,Tax ' || PCDB.TAX_STATUS
           END) Incoterm_details
      From PCDB_PC_DELIVERY_BASIS   PCDB,
           ITM_INCOTERM_MASTER      ITM,
           CIM_CITYMASTER           CIM,
           PCDIOB_DI_OPTIONAL_BASIS PCDIOB
     Where PCDB.INCO_TERM_ID = ITM.INCOTERM_ID
       AND PCDB.CITY_ID = CIM.CITY_ID
       AND PCDIOB.PCDB_ID = PCDB.PCDB_ID
       AND PCDB.IS_ACTIVE = 'Y'
       AND PCDIOB.IS_ACTIVE = 'Y'
       AND PCDIOB.PCDI_ID = p_delivery_id;
 
  cursor cr_pricing IS
     Select --PCBPH.PRICE_DESCRIPTION as PRICE_DESCRIPTION,
           PCBPH.ELEMENT_NAME      as ELEMENT_NAME,
           PCBPH.PCBPH_ID          as PCBPH_ID
      From PCDIPE_DI_PRICING_ELEMENTS PCDIPE,
           PCBPH_PC_BASE_PRICE_HEADER PCBPH
     Where PCDIPE.PCBPH_ID = PCBPH.PCBPH_ID
       AND PCDIPE.IS_ACTIVE = 'Y'
       AND PCBPH.IS_ACTIVE = 'Y'
       AND PCDIPE.PCDI_ID = p_delivery_id
     ORDER BY PCBPH.ELEMENT_NAME;
     
cursor cr_payble_content IS
SELECT   pcpch.pcpch_id AS pcpchid
    FROM pcpch_pc_payble_content_header pcpch,
         dipch_di_payablecontent_header dipch
   WHERE dipch.pcdi_id = p_delivery_id
     AND dipch.pcpch_id = pcpch.pcpch_id
     AND dipch.is_active = 'Y'
     AND pcpch.is_active = 'Y';

cursor cr_treatment_charge IS
SELECT   pcth.pcth_id AS pcthid
    FROM dith_di_treatment_header dith,
         pcth_pc_treatment_header pcth,
         ted_treatment_element_details ted
   WHERE dith.pcth_id = pcth.pcth_id
     AND pcth.pcth_id = ted.pcth_id
     AND pcth.is_active = 'Y'
     AND dith.is_active = 'Y'
     AND ted.is_active = 'Y'
     AND dith.pcdi_id = p_delivery_id
ORDER BY ted.element_name;

cursor cr_refining_charge IS
SELECT   pcrh.pcrh_id AS pcrhid
    FROM dirh_di_refining_header dirh,
         pcrh_pc_refining_header pcrh,
         red_refining_element_details red
   WHERE dirh.pcrh_id = pcrh.pcrh_id
     AND pcrh.pcrh_id = red.pcrh_id
     AND pcrh.is_active = 'Y'
     AND dirh.is_active = 'Y'
     AND red.is_active = 'Y'
     AND dirh.pcdi_id = p_delivery_id
ORDER BY red.element_name;
   

begin

  --begin
 --   select 'Delivery Item No :' || PCM.CONTRACT_REF_NO || '-' ||
  --         PCDI.DELIVERY_ITEM_NO
  --    into deliveryItem
  --    from PCDI_PC_DELIVERY_ITEM PCDI, PCM_PHYSICAL_CONTRACT_MAIN PCM
  --   Where PCM.INTERNAL_CONTRACT_REF_NO = PCDI.INTERNAL_CONTRACT_REF_NO
  --     and PCDI.PCDI_ID = p_delivery_id;
  
 -- exception
 --   when no_data_found then
 --     deliveryItem := '';
 -- end;
  
  BEGIN
      SELECT pcdi.packing_type
        INTO packingtype
        FROM pcdi_pc_delivery_item pcdi, pcm_physical_contract_main pcm
       WHERE pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
         AND pcdi.pcdi_id = p_delivery_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         packingtype := '';
   END;

  begin
  
    select 'Delivery Period :' || (CASE
             WHEN PCDI.DELIVERY_PERIOD_TYPE = 'Month' THEN
              PCDI.DELIVERY_FROM_MONTH || ' ' || PCDI.DELIVERY_FROM_YEAR ||
              ' To ' || PCDI.DELIVERY_TO_MONTH || ' ' ||
              PCDI.DELIVERY_TO_YEAR
             ELSE
              to_char(PCDI.DELIVERY_FROM_DATE, 'dd-Mon-YYYY') || ' To ' ||
              to_char(PCDI.DELIVERY_TO_DATE, 'dd-Mon-YYYY')
           END)
      into quotaPeriod
      from PCDI_PC_DELIVERY_ITEM PCDI
     Where PCDI.PCDI_ID = p_delivery_id;
  exception
    when no_data_found then
      quotaPeriod := '';
  end;

  begin
    select 'Quality :' || stragg(QAT.QUALITY_NAME)
      into qualityDetails
      From PCPQ_PC_PRODUCT_QUALITY   PCPQ,
           QAT_QUALITY_ATTRIBUTES    QAT,
           PCDIQD_DI_QUALITY_DETAILS PCDIQD
     Where PCPQ.QUALITY_TEMPLATE_ID = QAT.QUALITY_ID
       AND PCDIQD.PCPQ_ID = PCPQ.PCPQ_ID
       AND PCDIQD.PCDI_ID = p_delivery_id;
  exception
    when no_data_found then
      qualityDetails := '';
  end;

  begin
    Select PCDI.QTY_MIN_OPERATOR,
           PCDI.QTY_MIN_VAL,
           PCDI.QTY_MAX_OPERATOR,
           PCDI.QTY_MAX_VAL,
           QUM.QTY_UNIT_DESC
      into minQtyOp, minQtyValue, maxQtyOp, maxQtyValue, itemQtyUnit
      From PCDI_PC_DELIVERY_ITEM PCDI, QUM_QUANTITY_UNIT_MASTER QUM
     Where PCDI.QTY_UNIT_ID = QUM.QTY_UNIT_ID
       AND PCDI.PCDI_ID = p_delivery_id;
  
  exception
    when no_data_found then
      quantityDetails := '';
  end;

  if (minQtyValue = maxQtyValue) then
    quantityDetails := 'Quantity :' || minQtyValue || ' ' || itemQtyUnit;
  else
    quantityDetails := 'Quantity :' || 'Min ' || minQtyOp || ' ' ||
                       minQtyValue || ' Max ' || maxQtyOp || ' ' ||
                       maxQtyValue || ' ' || itemQtyUnit;
  end if;

  for incoterm_rec in cr_incoterm loop
    incotermDetails := chr(10) || 'Terms of Delivery :' ||
                       incoterm_rec.Incoterm_details;
  end loop;

  for pricing_rec in cr_pricing loop
  
    pricingDetails := pricingDetails || chr(10) ;
    if (pricing_rec.ELEMENT_NAME is not null) then
      pricingDetails := pricingDetails || pricing_rec.ELEMENT_NAME;
    end if;
    
    --pricingDetails := pricingDetails || pricing_rec.PRICE_DESCRIPTION;
          
    formulaDetails := getpricingformuladetails(pricing_rec.PCBPH_ID);
    if (formulaDetails is not null) then
      pricingDetails := pricingDetails || chr(10) || formulaDetails;
    end if;
  
  end loop;
  
  IF (product_group_type = 'CONCENTRATES')
   THEN
  for payble_content_rec in cr_payble_content loop
     IF(istollingcontract = 'N')
      THEN
        pcDetails := getpayablecontentdetails(payble_content_rec.pcpchid);
      else
        pcDetails := gettolpayablecontentdetails(payble_content_rec.pcpchid);
        returnableDetails := getreturnablecontentdetails(payble_content_rec.pcpchid);
      end if;
    
    if (pcDetails is not null) then
      payableContent := chr(10) || 'Payable Content: ' || chr(10) || pcDetails ;
    end if;
     if (returnableContent is not null) then
      returnableContent := 'Returnable Content: ' || chr(10) || returnableDetails || chr(10);
    end if;
    
    
  end loop;
  
  for tc_rec in cr_treatment_charge loop
    treatmentCharge := getTCDetails(tc_rec.pcthid);
    if (treatmentCharge is not null) then
    tcDetails := tcDetails || chr(10) || treatmentCharge ;
    end if;
    
  end loop;
  
   for rc_rec in cr_refining_charge loop
    
    refiningCharge := getRCDetails(rc_rec.pcrhid);
    if (refiningCharge is not null) then
    rcDetails := rcDetails || chr(10) || refiningCharge ;
    end if;
    
  end loop;
  end if;

  begin
    Select nvl(to_char(PCDI.QP_DECLARATION_DATE, 'DD-Mon-YYYY'), ''),
           nvl(PCDI.QUALITY_OPTION_TYPE, ''),
           nvl(to_char(PCDI.PAYMENT_DUE_DATE, 'DD-Mon-YYYY'), '')
      into QPDeclarationDate, Optionality, PaymentDueDate
      From PCDI_PC_DELIVERY_ITEM PCDI
     Where PCDI.PCDI_ID = p_delivery_id;
  exception
    when no_data_found then
      QPDeclarationDate := '';
      Optionality       := '';
      PaymentDueDate    := '';  
  end;

  deliveryDescription := qualityDetails  || CHR(10) || quantityDetails || CHR(10) ||  quotaPeriod || chr(10) ||
                         incotermDetails || chr(10);
         
  if (packingtype is not null) then                
  deliveryDescription := deliveryDescription || 'Packing Type: '||packingtype || chr(10);
  end if;
  
  deliveryDescription := deliveryDescription || Optionality || chr(10) || pricingDetails ||
                         payableContent  || tcDetails || chr(10) || rcDetails || chr(10);

  if (QPDeclarationDate is not null) then
    deliveryDescription := deliveryDescription || chr(10) ||
                           'QP declaration Date:' || QPDeclarationDate;
  end if;

--  if (PaymentDueDate is not null) then
--    deliveryDescription := deliveryDescription || chr(10) ||
--                           'Payment Due Date:' || PaymentDueDate;
--  end if;

  return deliveryDescription;

end;
/
