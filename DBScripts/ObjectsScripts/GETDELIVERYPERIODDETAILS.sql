CREATE OR REPLACE FUNCTION GETDELIVERYPERIODDETAILS(p_contractNo  VARCHAR2,
                                                    p_delivery_id VARCHAR2)
  return CLOB is
  deliveryDescription CLOB := '';
  deliveryItem        VARCHAR2(4000) := '';
  quotaPeriod         VARCHAR2(4000) := '';
  qualityDetails      VARCHAR2(4000) := '';
  quantityDetails     VARCHAR2(4000) := '';
  incotermDetails     VARCHAR2(4000) := 'Incoterm-Location:';
  pricingDetails      VARCHAR2(4000) := 'Price Description :';
  formulaDetails      VARCHAR2(4000) := '';
  QPDeclarationDate   VARCHAR2(50);
  PaymentDueDate      VARCHAR2(50);
  Optionality         VARCHAR2(50);
  minQtyOp            VARCHAR2(15);
  maxQtyOp            VARCHAR2(15);
  minQtyValue         NUMBER(25, 10);
  maxQtyValue         NUMBER(25, 10);
  itemQtyUnit         VARCHAR2(50);

  cursor cr_incoterm IS
    Select ITM.INCOTERM || ' - ' || CIM.CITY_NAME || (case
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
    Select PCBPH.PRICE_DESCRIPTION as PRICE_DESCRIPTION,
           PCBPH.ELEMENT_NAME      as ELEMENT_NAME,
           PCBPH.PCBPH_ID          as PCBPH_ID
      From PCDIPE_DI_PRICING_ELEMENTS PCDIPE,
           PCBPH_PC_BASE_PRICE_HEADER PCBPH
     Where PCDIPE.PCBPH_ID = PCBPH.PCBPH_ID
       AND PCDIPE.IS_ACTIVE = 'Y'
       AND PCBPH.IS_ACTIVE = 'Y'
       AND PCDIPE.PCDI_ID = p_delivery_id
     ORDER BY PCDIPE.PCBPH_ID;

begin

  begin
    select 'Delivery Item No :' || PCM.CONTRACT_REF_NO || '-' ||
           PCDI.DELIVERY_ITEM_NO
      into deliveryItem
      from PCDI_PC_DELIVERY_ITEM PCDI, PCM_PHYSICAL_CONTRACT_MAIN PCM
     Where PCM.INTERNAL_CONTRACT_REF_NO = PCDI.INTERNAL_CONTRACT_REF_NO
       and PCDI.PCDI_ID = p_delivery_id;
  
  exception
    when no_data_found then
      deliveryItem := '';
  end;

  begin
  
    select 'Quota Period :' || (CASE
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
           f_format_to_char(PCDI.QTY_MIN_VAL, 4),
           PCDI.QTY_MAX_OPERATOR,
           f_format_to_char(PCDI.QTY_MAX_VAL, 4),
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
    incotermDetails := chr(10) || 'Incoterm-Location :' ||
                       incoterm_rec.Incoterm_details;
  end loop;

  for pricing_rec in cr_pricing loop
  
    pricingDetails := pricingDetails || chr(10);
    if (pricing_rec.ELEMENT_NAME is not null) then
      pricingDetails := pricingDetails || pricing_rec.ELEMENT_NAME || ' :';
    end if;
    pricingDetails := pricingDetails || pricing_rec.PRICE_DESCRIPTION;
  
    formulaDetails := getpricingformuladetails(pricing_rec.PCBPH_ID);
    if (formulaDetails is not null) then
      pricingDetails := pricingDetails || chr(10) || formulaDetails || chr(10);
    end if;
  
  end loop;

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

  deliveryDescription := deliveryItem || chr(10) || quotaPeriod || chr(10) ||
                         qualityDetails || chr(10) || quantityDetails ||
                         incotermDetails || ' ' || Optionality || chr(10) ||
                         pricingDetails;

  if (QPDeclarationDate is not null) then
    deliveryDescription := deliveryDescription || chr(10) ||
                           'QP declaration Date:' || QPDeclarationDate;
  end if;

  if (PaymentDueDate is not null) then
    deliveryDescription := deliveryDescription || chr(10) ||
                           'Payment Due Date:' || PaymentDueDate;
  end if;

  return deliveryDescription;

end;
/
