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
  pricingDetails      VARCHAR2(4000) := 'Pricing of Payable metals:';
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
  tcDetails           VARCHAR2(4000) := '';
  refiningCharge      VARCHAR2(4000) := '';
  rcDetails           VARCHAR2(4000) := '';
  penalties           VARCHAR2(4000) := '';
  penaltyDetails      VARCHAR2(4000) := '';
  smallotcharge       VARCHAR2(4000) := '';
  containercharge     VARCHAR2(4000) := '';
  othercharge         VARCHAR2(4000) := '';
  pcquality           VARCHAR2(4000) := '';
  returnablequality   VARCHAR2(4000) := '';
  tcquality           VARCHAR2(4000) := '';
  treatmentdetails    VARCHAR2(4000) := '';
  rcquality           VARCHAR2(4000) := '';
  refiningdetails     VARCHAR2(4000) := '';
  penalty             VARCHAR2(4000) := '';
  penaltyquality      VARCHAR2(4000) := '';
  unitofmeasure       VARCHAR2(50);
  premium             VARCHAR2(4000) := '';

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
SELECT pcpch.pcpch_id AS pcpchid, 
       pqd.quality_name AS qualityname
  FROM pcpch_pc_payble_content_header pcpch,
       dipch_di_payablecontent_header dipch,
       pqd_payable_quality_details pqd,
       aml_attribute_master_list aml
 WHERE dipch.pcdi_id = p_delivery_id
   AND pcpch.pcpch_id = dipch.pcpch_id
   AND pqd.pcpch_id = pcpch.pcpch_id
   AND aml.attribute_id = pcpch.element_id
   AND pcpch.payable_type = 'Payable'
   AND pqd.is_active = 'Y'
   AND pcpch.is_active = 'Y'
   AND aml.is_active='Y'
   AND aml.is_deleted='N'
   order by pqd.quality_name,aml.attribute_name;

cursor cr_pc_quality          
    IS
SELECT DISTINCT pqd.quality_name AS qualityname
           FROM pcpch_pc_payble_content_header pcpch,
                dipch_di_payablecontent_header dipch,
                pqd_payable_quality_details pqd
          WHERE dipch.pcdi_id = p_delivery_id
            AND pcpch.pcpch_id = dipch.pcpch_id
            AND pqd.pcpch_id = pcpch.pcpch_id
            AND pcpch.payable_type = 'Payable'
            AND pqd.is_active = 'Y'
            AND pcpch.is_active = 'Y'
            order by pqd.quality_name;
            
cursor cr_returnable_content IS
SELECT pcpch.pcpch_id AS pcpchid, pqd.quality_name AS qualityname
  FROM pcpch_pc_payble_content_header pcpch,
       dipch_di_payablecontent_header dipch,
       pqd_payable_quality_details pqd,
       aml_attribute_master_list aml
 WHERE dipch.pcdi_id = p_delivery_id
   AND pcpch.pcpch_id = dipch.pcpch_id
   AND pqd.pcpch_id = pcpch.pcpch_id
   AND aml.attribute_id = pcpch.element_id
   AND pcpch.payable_type = 'Returnable'
   AND pqd.is_active = 'Y'
   AND pcpch.is_active = 'Y'
   AND aml.is_active='Y'
   AND aml.is_deleted='N'
   order by pqd.quality_name,aml.attribute_name;

cursor cr_retuanable_quality          
    IS
SELECT DISTINCT pqd.quality_name AS qualityname
           FROM pcpch_pc_payble_content_header pcpch,
                dipch_di_payablecontent_header dipch,
                pqd_payable_quality_details pqd
          WHERE dipch.pcdi_id = p_delivery_id
            AND pcpch.pcpch_id = dipch.pcpch_id
            AND pqd.pcpch_id = pcpch.pcpch_id
            AND pcpch.payable_type = 'Returnable'
            AND pqd.is_active = 'Y'
            AND pcpch.is_active = 'Y'
            order by pqd.quality_name;            

cursor cr_treatment_charge IS
SELECT   pcth.pcth_id AS pcthid, 
         tqd.quality_name as qualityname
    FROM dith_di_treatment_header dith,
         pcth_pc_treatment_header pcth,
         tqd_treatment_quality_details tqd,
         ted_treatment_element_details ted
   WHERE dith.pcth_id = pcth.pcth_id
     AND tqd.pcth_id = pcth.pcth_id
     AND ted.pcth_id = pcth.pcth_id
     AND pcth.is_active = 'Y'
     AND dith.is_active = 'Y'
     AND ted.is_active  = 'Y'
     AND dith.pcdi_id = p_delivery_id
ORDER BY tqd.quality_name, ted.element_name;

cursor cr_tc_quality IS
SELECT DISTINCT tqd.quality_name as qualityname
           FROM dith_di_treatment_header dith,
                pcth_pc_treatment_header pcth,
                tqd_treatment_quality_details tqd
          WHERE dith.pcth_id = pcth.pcth_id
            AND tqd.pcth_id = pcth.pcth_id
            AND pcth.is_active = 'Y'
            AND dith.is_active = 'Y'
            AND dith.pcdi_id = p_delivery_id
       ORDER BY tqd.quality_name;

cursor cr_refining_charge IS
SELECT   pcrh.pcrh_id AS pcrhid, 
         rqd.quality_name as qualityname
    FROM dirh_di_refining_header dirh,
         pcrh_pc_refining_header pcrh,
         rqd_refining_quality_details rqd,
         red_refining_element_details red
   WHERE dirh.pcrh_id = pcrh.pcrh_id
     AND rqd.pcrh_id = pcrh.pcrh_id
     AND red.pcrh_id = pcrh.pcrh_id
     AND pcrh.is_active = 'Y'
     AND dirh.is_active = 'Y'
     AND rqd.is_active = 'Y'
     AND red.is_active ='Y'
     AND dirh.pcdi_id = p_delivery_id
ORDER BY rqd.quality_name,red.element_name;
   
cursor cr_rc_quality IS
SELECT DISTINCT rqd.quality_name as qualityname
           FROM dirh_di_refining_header dirh,
                pcrh_pc_refining_header pcrh,
                rqd_refining_quality_details rqd
          WHERE dirh.pcrh_id = pcrh.pcrh_id
            AND rqd.pcrh_id = pcrh.pcrh_id
            AND pcrh.is_active = 'Y'
            AND dirh.is_active = 'Y'
            AND rqd.is_active = 'Y'
            AND dirh.pcdi_id = p_delivery_id
       ORDER BY rqd.quality_name;

cursor cr_penalties IS
SELECT   pcaph.pcaph_id AS pcaphid, 
         pqd.quality_name AS qualityname
    FROM diph_di_penalty_header diph,
         pcaph_pc_attr_penalty_header pcaph,
         pqd_penalty_quality_details pqd,
         pad_penalty_attribute_details pad
   WHERE diph.pcaph_id = pcaph.pcaph_id
     AND diph.pcaph_id = pqd.pcaph_id
     AND pad.pcaph_id = pcaph.pcaph_id
     AND diph.is_active = 'Y'
     AND pcaph.is_active = 'Y'
     AND pad.is_active= 'Y'
     AND diph.pcdi_id = p_delivery_id
ORDER BY pqd.quality_name, pad.element_name;

cursor cr_penalties_quality IS
SELECT   distinct pqd.quality_name AS qualityname
    FROM diph_di_penalty_header diph,
         pcaph_pc_attr_penalty_header pcaph,
         pqd_penalty_quality_details pqd
   WHERE diph.pcaph_id = pcaph.pcaph_id
     AND diph.pcaph_id = pqd.pcaph_id
     AND diph.is_active = 'Y'
     AND pcaph.is_active = 'Y'
     AND diph.pcdi_id = p_delivery_id
ORDER BY pqd.quality_name;
   
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
    select 'Quality: ' || stragg(QAT.QUALITY_NAME)
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
           PCDI.UNIT_OF_MEASURE,
           QUM.QTY_UNIT_DESC
      into minQtyOp, minQtyValue, maxQtyOp, maxQtyValue,unitofmeasure, itemQtyUnit
      From PCDI_PC_DELIVERY_ITEM PCDI, QUM_QUANTITY_UNIT_MASTER QUM
     Where PCDI.QTY_UNIT_ID = QUM.QTY_UNIT_ID
       AND PCDI.PCDI_ID = p_delivery_id;
  
  exception
    when no_data_found then
      quantityDetails := '';
  end;

  if (minQtyValue = maxQtyValue) then
    quantityDetails := 'Quantity: ' || minQtyValue || ' ' || unitofmeasure || ''|| itemQtyUnit;
  else
    quantityDetails := 'Quantity: ' || 'Min ' || minQtyOp || ' ' ||
                       minQtyValue || ' Max ' || maxQtyOp || ' ' ||
                       maxQtyValue || ' ' || unitofmeasure || ' '|| itemQtyUnit;
  end if;

  for incoterm_rec in cr_incoterm loop
    incotermDetails := chr(10) || 'Terms of Delivery: ' ||
                       incoterm_rec.Incoterm_details;
  end loop;

    -- Pricing 
  for pricing_rec in cr_pricing loop
  pricingDetails := pricingDetails || chr(10) ;
    if (pricing_rec.ELEMENT_NAME is not null) then
      pricingDetails := pricingDetails || pricing_rec.ELEMENT_NAME;
    end if;
    
    formulaDetails := getpricingformuladetails(pricing_rec.PCBPH_ID);
    if (formulaDetails is not null) then
      pricingDetails := pricingDetails || chr(10) || formulaDetails;
    end if;
  
  end loop;
  
  IF (product_group_type = 'CONCENTRATES')
   THEN
   
   --Payable Content 
   for pc_quality_rec in cr_pc_quality loop
    for payble_content_rec in cr_payble_content loop
             if(pc_quality_rec.qualityname  = payble_content_rec.qualityname) then  
               pcquality:= payble_content_rec.qualityname;
               IF(istollingcontract = 'N')
                THEN
                pcDetails := getpayablecontentdetails(payble_content_rec.pcpchid);
                else
                pcDetails := pcDetails || gettolpayablecontentdetails(payble_content_rec.pcpchid);
                end if;
             end if;
    end loop;
             payableContent := payableContent || chr(10) || pcquality || chr(10) || pcDetails;
             pcDetails := '';
             pcquality := '';
   end loop;
   
  -- payableContent := payableContent || chr(10) || pcquality || chr(10) || pcDetails;
   
   --Returnable Content
   IF(istollingcontract = 'N') then
    for retuanable_quality_rec in cr_retuanable_quality loop
     for returnable_content_rec in cr_returnable_content loop
             if(retuanable_quality_rec.qualityname  = returnable_content_rec.qualityname) then  
               returnablequality := returnable_content_rec.qualityname;
               returnableDetails :=  returnableDetails || getreturnablecontentdetails(returnable_content_rec.pcpchid);
                end if;
             
     end loop;
             returnableContent := returnableContent || chr(10) || pcquality ||chr(10) || returnableDetails;
             returnableDetails := '';
             returnablequality := '';
    end loop;
   end if;
   
   --returnableContent := returnableContent || chr(10) || pcquality ||chr(10) || returnableDetails;
  
   -- Treatment Charge
   for tc_quality_rec in cr_tc_quality loop
    for treatment_charge_rec in cr_treatment_charge loop
             if(tc_quality_rec.qualityname  = treatment_charge_rec.qualityname) then  
               tcquality:= treatment_charge_rec.qualityname;
               treatmentCharge := treatmentCharge || getTCDetails(treatment_charge_rec.pcthid);
             end if;
    end loop;
             tcDetails := tcDetails || chr(10) || tcquality || chr(10) || treatmentCharge;
             treatmentCharge := '';
             tcquality := '';
   end loop;
  
   --Refining Charge
   for rc_quality_rec in cr_rc_quality loop
    for refining_charge_rec in cr_refining_charge loop
             if(rc_quality_rec.qualityname  = refining_charge_rec.qualityname) then  
               rcquality:= refining_charge_rec.qualityname;
               refiningCharge := refiningCharge || getRCDetails(refining_charge_rec.pcrhid);
             end if;
    end loop;
             rcDetails := rcDetails || chr(10) || rcquality || chr(10) || refiningCharge;
             refiningCharge := '';
             rcquality := '';
   end loop;
   
    --Penalty 
    for penalties_quality_rec in cr_penalties_quality loop
    for penalties_rec in cr_penalties loop
             if(penalties_quality_rec.qualityname  = penalties_rec.qualityname) then  
               penaltyquality:= penalties_rec.qualityname;
               penalty := penalty || getPenaltyDetails(penalties_rec.pcaphid);
             end if;
    end loop;
             penaltyDetails := penaltyDetails || chr(10) || penaltyquality || chr(10) || penalty;
             penalty := '';
             penaltyquality := '';
   end loop;
  
  end if;
  
  smallotcharge := getslcdetails (p_contractno);
  containercharge := getccdetails (p_contractno);
  othercharge := getocdetails (p_contractno);
  premium := getqualitylocationpremuim(p_delivery_id);
  

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
  
  deliveryDescription := deliveryDescription || Optionality || chr(10) || pricingDetails || chr(10);
 
  if(payableContent is not null) then
  deliveryDescription := deliveryDescription || 'Payable Content:' || payableContent || chr(10);
  end if; 
  
  if(returnableContent is not null) then
  deliveryDescription := deliveryDescription || 'Returnable Content:' || returnableContent || chr(10);
  end if;                   
                         
  if (tcDetails is not null) then     
  deliveryDescription := deliveryDescription || chr(10) || 'Treatment Charges: ' || tcDetails;    
  end if;
    
  if (rcDetails is not null)  then
  deliveryDescription := deliveryDescription || chr(10) || 'Refining Charges: ' || rcDetails;
  end if;
  
  if (penaltyDetails is not null)  then
  deliveryDescription := deliveryDescription || chr(10) || 'Penalties: ' || penaltyDetails;
  end if;
  
  if (smallotcharge is not null) then
  deliveryDescription := deliveryDescription || chr(10) || 'Small Lot Charges: '|| smallotcharge;
  end if;
    
  if (containercharge is not null) then
  deliveryDescription := deliveryDescription || chr(10) || 'Container Charges: '|| containercharge;
  end if;
  
  if (othercharge is not null) then 
   deliveryDescription := deliveryDescription || chr(10) || 'Other Charges: '|| chr(10) ||othercharge;
  end if;
  
  if (premium is not null) then 
   deliveryDescription := deliveryDescription || chr(10) || 'Premium: '|| chr(10) ||premium;
  end if;
  
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
