CREATE OR REPLACE procedure generateContractOutputDoc (
      p_contractNo        VARCHAR2,
      p_docrefno          VARCHAR2,
      p_activity_id       VARCHAR2
   )

   IS
      docId  VARCHAR2(15);
      contractSection  VARCHAR2(50) :='Contract Buyer Section';
      issueDate         VARCHAR2 (50);
      ContractRefNo     VARCHAR2 (50);
      CPContractRefNo   VARCHAR2 (50);
      CorporateId       VARCHAR2(20);
      CorporateName     VARCHAR2(20);
      ContractType      VARCHAR2(20);
      CpId              VARCHAR2(20);
      counterparty      VARCHAR2(200);
      traxysTrader    varchar2(200);
      cpContactPersoson    varchar2(200);
      buyer     varchar2(200);
      seller     varchar2(200);
      CpAddress  varchar2(4000);
      ProductDef  varchar2(4000);
      display_order number(10) :=1;
      pcdi_count number(10) :=1;
      deliveryScheduleComments VARCHAR2(4000) :='';
      paymentDetails VARCHAR2(4000) :='';
      paymentText VARCHAR2(4000) :='';
      taxes VARCHAR2(4000) :='';
      insuranceTerms VARCHAR2(4000) :='';
      otherTerms VARCHAR2(4000) :='';
      PRODUCT_GROUP_TYPE VARCHAR2(50):='';
      qualityPrintNameReq VARCHAR2(15):='';
      qualityPrintName VARCHAR2(1000):='';


cursor cr_delivery
    IS
Select PCDI.PCDI_ID PCDI_ID,(pcm.contract_ref_no || '-' || pcdi.delivery_item_no ) AS delivery_item_ref_no
From PCDI_PC_DELIVERY_ITEM PCDI, PCM_PHYSICAL_CONTRACT_MAIN PCM
Where PCDI.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO AND
PCM.INTERNAL_CONTRACT_REF_NO =p_contractNo
and PCDI.IS_ACTIVE = 'Y'
order by pcdi.delivery_item_no;

BEGIN

    select SEQ_CONT_OP.nextval into docId from dual;
    begin
    Select to_char(PCM.ISSUE_DATE ,'dd-Mon-YYYY'),PCM.CONTRACT_REF_NO,nvl(PCM.CP_CONTRACT_REF_NO,'NA') ,AK.CORPORATE_NAME,AK.CORPORATE_ID,PCM.PURCHASE_SALES,
        PHD.COMPANYNAME,PCM.CP_ID,PCM.PRODUCT_GROUP_TYPE
        INTO issueDate,ContractRefNo,CPContractRefNo,CorporateName,CorporateId,ContractType,counterparty,CpId,PRODUCT_GROUP_TYPE
        From PCM_PHYSICAL_CONTRACT_MAIN PCM, AK_CORPORATE AK,PHD_PROFILEHEADERDETAILS PHD
        Where PCM.CORPORATE_ID = AK.CORPORATE_ID AND PHD.PROFILEID = PCM.CP_ID AND    PCM.INTERNAL_CONTRACT_REF_NO  =p_contractNo;

    exception
              when no_data_found then
                issueDate := '';
                ContractRefNo:= '';
                CPContractRefNo:='';
                CorporateName:='';
                CorporateId:='';
                ContractType:='';
                counterparty:='';
                CpId:='';
                PRODUCT_GROUP_TYPE:='';


    end;
    if (ContractType = 'P') then
        buyer:=CorporateName;
        seller :=counterparty;
        contractSection  :='Contract Buyer Section';
    else
        buyer:=counterparty;
        seller:=CorporateName;
        contractSection  :='Contract Seller Section';
    end if;

Insert into COS_CONTRACT_OUTPUT_SUMMARY
   (DOC_ID, DOC_TYPE, TEMPLATE_TYPE, TEMPLATE_NAME, INTERNAL_DOC_REF_NO,
    VER_NO, ISSUE_DATE, IS_AMENDMENT, STATUS, CREATED_BY,
    CREATED_DATE, UPDATED_BY, UPDATED_DATE, CANCELLED_BY, CANCELLED_DATE,
    SEND_DATE, RECEIVED_DATE, INTERNAL_CONTRACT_REF_NO, CONTRACT_REF_NO, CONTRACT_TYPE,
    CORPORATE_ID, CONTRACT_SIGNING_DATE, APPROVAL_TYPE, AMENDMENT_NO, WATERMARK,
    AMENDMENT_DATE, DOCUMENT_PRINT_TYPE)
 Values
   (docId, 'ORIGINAL', NULL, NULL, p_docrefno,
    1, issueDate, 'N', 'Active', NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, p_contractNo, ContractRefNo, ContractType,
    CorporateId, NULL, NULL, NULL, NULL,
    NULL, 'Full Contract');
    
    Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, contractSection, 'Contract Ref No',
    'Y', NULL, NULL, ContractRefNo, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');
    
   display_order:=display_order+1;
    
    Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, contractSection, 'Counterparty Contract Ref No',
    'Y', NULL, NULL, CPContractRefNo, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');

    begin
       Select nvl((GAB.FIRSTNAME ||' ' ||  GAB.LASTNAME ), 'NA')   into traxysTrader from AK_CORPORATE_USER AKU, GAB_GLOBALADDRESSBOOK GAB Where GAB.GABID = AKU.GABID
       AND AKU.USER_ID IN ( Select PCM.TRADER_ID  From PCM_PHYSICAL_CONTRACT_MAIN PCM Where PCM.INTERNAL_CONTRACT_REF_NO = p_contractNo);

    exception
        when no_data_found then
          traxysTrader := null;
    end;

    begin
        Select GAB.FIRSTNAME ||' ' ||  GAB.LASTNAME   into cpContactPersoson from GAB_GLOBALADDRESSBOOK GAB Where GAB.GABID =
        ( Select PCM.CP_PERSON_IN_CHARGE_ID  From PCM_PHYSICAL_CONTRACT_MAIN PCM Where PCM.INTERNAL_CONTRACT_REF_NO = p_contractNo);
    exception
    when no_data_found then
      cpContactPersoson := null;
    end;


  display_order:=display_order+1;
Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, contractSection, 'Traxys Trader',
    'Y', NULL, NULL, traxysTrader, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');
   display_order:=display_order+1;
 Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, contractSection, ' CP Trader name',
    'Y', NULL, NULL, cpContactPersoson, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');

   display_order := display_order + 1;

   Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, contractsection, 'Contract Issue Date',
    'Y', NULL, NULL, issueDate, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');

   display_order:=display_order+1;
 Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, contractSection, 'Buyer',
    'Y', NULL, NULL, buyer, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');
     display_order:=display_order+1;
  Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, contractSection, 'Seller',
    'Y', NULL, NULL, seller, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');
 
    begin
    select PAD.address || ','||  CIM.CITY_NAME|| ','||SM.STATE_NAME|| ','|| CYM.COUNTRY_NAME into CpAddress
    from PAD_PROFILE_ADDRESSES PAD ,CYM_COUNTRYMASTER CYM, CIM_CITYMASTER CIM, SM_STATE_MASTER SM
    Where PAD.ADDRESS_TYPE='Main' AND
    PAD.COUNTRY_ID = CYM.COUNTRY_ID AND
    PAD .CITY_ID(+) = CIM.CITY_ID AND
    CIM.STATE_ID(+) = SM.STATE_ID AND
    PAD.PROFILE_ID=CpId  and PAD.IS_DELETED='N';
    exception
        when no_data_found then
          CpAddress := null;
    end;

    display_order:=display_order+1;
  Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, 'Counter Party', 'CP Address',
    'Y', NULL, NULL, CpAddress, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');

    begin
    select PDM.PRODUCT_DESC || chr(10)||
           (CASE
              WHEN PCPD.QTY_TYPE ='Fixed'
                 THEN  f_format_to_char(PCPD.QTY_MAX_VAL,4) || ' '|| QUM.QTY_UNIT_DESC
              ELSE PCPD.QTY_MIN_OPERATOR ||' '||   f_format_to_char(PCPD.QTY_MIN_VAL,4) ||' '||  PCPD.QTY_MAX_OPERATOR ||' '||   f_format_to_char(PCPD.QTY_MAX_VAL,4) || ' '|| QUM.QTY_UNIT_DESC
              END
          )
           into ProductDef
    from PCPD_PC_PRODUCT_DEFINITION  PCPD, PDM_PRODUCTMASTER PDM,QUM_QUANTITY_UNIT_MASTER QUM
    Where PCPD.PRODUCT_ID = PDM.PRODUCT_ID AND PCPD.QTY_UNIT_ID = QUM.QTY_UNIT_ID
    AND PCPD.INTERNAL_CONTRACT_REF_NO = p_contractNo;

    exception
            when no_data_found then
              ProductDef := '';
    end;

    display_order:=display_order+1;

  Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, 'Product and Quantity', 'Product and Quantity',
    'Y', NULL, NULL, ProductDef, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');
    display_order:=display_order+1;

  begin
  select PCPD.IS_QUALITY_PRINT_NAME_REQ,pcpd.QUALITY_PRINT_NAME  into qualityPrintNameReq,qualityPrintName
    from PCPD_PC_PRODUCT_DEFINITION pcpd,
         PCM_PHYSICAL_CONTRACT_MAIN pcm
    where PCPD.INTERNAL_CONTRACT_REF_NO = PCM.INTERNAL_CONTRACT_REF_NO
     AND PCPD.INTERNAL_CONTRACT_REF_NO =p_contractNo;
  end;   
  if (qualityPrintNameReq = 'Y') then  

      Insert into COD_CONTRACT_OUTPUT_DETAIL
       (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
        IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
        POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
        IS_CHANGED)
     Values
       (docId, display_order, NULL, 'Quality/Qualities', 'Quality/Qualities',
        'Y', NULL, NULL, qualityPrintName, NULL,
        NULL, 'N', 'N', 'N', 'FULL',  'N');
  else
    
      Insert into COD_CONTRACT_OUTPUT_DETAIL
       (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
        IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
        POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
        IS_CHANGED)
     Values
       (docId, display_order, NULL, 'Quality/Qualities', 'Quality/Qualities',
        'Y', NULL, NULL, getContractQualityDetails(p_contractNo), NULL,
        NULL, 'N', 'N', 'N', 'FULL',  'N');  
   
  end if;     
        
   
    for delivery_rec in cr_delivery
    loop
        display_order := display_order+1;
        Insert into COD_CONTRACT_OUTPUT_DETAIL
       (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
        IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
        POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
        IS_CHANGED)
     Values
       (docId, display_order, NULL, 'Time of Shipment', 'Delivery Item:'|| delivery_rec.delivery_item_ref_no,
        'Y', NULL, NULL, getDeliveryPeriodDetails(p_contractNo,delivery_rec.PCDI_ID), NULL,
        NULL, 'N', 'N', 'N', 'FULL',  'N');
    end loop;

    begin
        select PCM.DEL_SCHEDULE_COMMENTS into deliveryScheduleComments from PCM_PHYSICAL_CONTRACT_MAIN PCM
        Where PCM.INTERNAL_CONTRACT_REF_NO = p_contractNo;
    exception
        when no_data_found then
          deliveryScheduleComments := '';
    end;

   display_order:=display_order+1;

  Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, 'Time of Shipment', 'Other Terms',
    'Y', NULL, NULL, deliveryScheduleComments, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');

    begin

    Select  CM.CUR_CODE || ' ,'|| PYM.PAYTERM_LONG_NAME || (CASE
              WHEN PCM.PROVISIONAL_PYMT_PCTG IS NULL
                 THEN ''
              ELSE ', '||PCM.PROVISIONAL_PYMT_PCTG|| ' % of Provisional Invoice Amount'
              END
          )   into paymentDetails
    From PCM_PHYSICAL_CONTRACT_MAIN PCM , PYM_PAYMENT_TERMS_MASTER PYM, CM_CURRENCY_MASTER CM
    Where PCM.PAYMENT_TERM_ID = PYM.PAYMENT_TERM_ID AND
    CM.CUR_ID = PCM.INVOICE_CURRENCY_ID AND PCM.INTERNAL_CONTRACT_REF_NO = p_contractNo;

    exception
        when no_data_found then
          paymentDetails := '';
    end;

  display_order:=display_order+1;

  Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, 'Payment Terms', 'Payment Terms',
    'Y', NULL, NULL, paymentDetails, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');

   if (PRODUCT_GROUP_TYPE = 'CONCENTRATES') then
       display_order:=display_order+1;

        Insert into COD_CONTRACT_OUTPUT_DETAIL
       (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
        IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
        POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
        IS_CHANGED)
     Values
       (docId, display_order, NULL, 'Payable Content', 'Payable Content',
        'Y', NULL, NULL, getPayableContentDetails(p_contractNo), NULL,
        NULL, 'N', 'N', 'N', 'FULL',  'N');

        display_order:=display_order+1;

       Insert into COD_CONTRACT_OUTPUT_DETAIL
       (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
        IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
        POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
        IS_CHANGED)
     Values
       (docId, display_order, NULL, 'Treatment Charges', 'Treatment Charges',
        'Y', NULL, NULL, getTCDetails(p_contractNo), NULL,
        NULL, 'N', 'N', 'N', 'FULL',  'N');

        display_order:=display_order+1;

       Insert into COD_CONTRACT_OUTPUT_DETAIL
       (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
        IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
        POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
        IS_CHANGED)
     Values
       (docId, display_order, NULL, 'Refining Charges', 'Refining Charges',
        'Y', NULL, NULL, getRCDetails(p_contractNo), NULL,
        NULL, 'N', 'N', 'N', 'FULL',  'N');

        display_order:=display_order+1;

       Insert into COD_CONTRACT_OUTPUT_DETAIL
       (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
        IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
        POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
        IS_CHANGED)
     Values
       (docId, display_order, NULL, 'Penalties', 'Penalties',
        'Y', NULL, NULL, getPenaltyDetails(p_contractNo), NULL,
        NULL, 'N', 'N', 'N', 'FULL',  'N');

      display_order:=display_order+1;

       Insert into COD_CONTRACT_OUTPUT_DETAIL
       (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
        IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
        POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
        IS_CHANGED)
     Values
       (docId, display_order, NULL, 'Assaying Rules', 'Assaying Rules',
        'Y', NULL, NULL, getAssayinRules(p_contractNo), NULL,
        NULL, 'N', 'N', 'N', 'FULL',  'N');

    end if;

    begin
        select PCM.PAYMENT_TEXT into paymentText from PCM_PHYSICAL_CONTRACT_MAIN PCM
        Where PCM.INTERNAL_CONTRACT_REF_NO = p_contractNo;
    exception
        when no_data_found then
        paymentText := '';
    end;

   display_order:=display_order+1;

  Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, 'Payment Text', 'Payment Text',
    'Y', NULL, NULL, paymentText, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');


   begin
        select PCM.TAXES into taxes from PCM_PHYSICAL_CONTRACT_MAIN PCM
        Where PCM.INTERNAL_CONTRACT_REF_NO = p_contractNo;
    exception
        when no_data_found then
        taxes := '';
    end;

   display_order:=display_order+1;

  Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
 Values
   (docId, display_order, NULL, 'Taxes, Tarrifs and Duties', 'Terms ',
    'Y', NULL, NULL, taxes, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');



    begin
        select PCM.INSURANCE into insuranceTerms from PCM_PHYSICAL_CONTRACT_MAIN PCM
        Where PCM.INTERNAL_CONTRACT_REF_NO = p_contractNo;
    exception
        when no_data_found then
        insuranceTerms := '';
    end;

   display_order:=display_order+1;

  Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
  Values
   (docId, display_order, NULL, 'Insurance', 'Insurance Terms ',
    'Y', NULL, NULL, insuranceTerms, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');


     begin
        select PCM.OTHER_TERMS into otherTerms from PCM_PHYSICAL_CONTRACT_MAIN PCM
        Where PCM.INTERNAL_CONTRACT_REF_NO = p_contractNo;
    exception
        when no_data_found then
        otherTerms := '';
    end;

   display_order:=display_order+1;

   Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
  Values
   (docId, display_order, NULL, 'Other Terms', 'Other Terms ',
    'Y', NULL, NULL, otherTerms, NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');
    
   display_order:=display_order+1;

   Insert into COD_CONTRACT_OUTPUT_DETAIL
   (DOC_ID, DISPLAY_ORDER, FIELD_LAYOUT_ID, SECTION_NAME, FIELD_NAME,
    IS_PRINT_REQD, PRE_CONTENT_TEXT_ID, POST_CONTENT_TEXT_ID, CONTRACT_CONTENT, PRE_CONTENT_TEXT,
    POST_CONTENT_TEXT, IS_CUSTOM_SECTION, IS_FOOTER_SECTION, IS_AMEND_SECTION, PRINT_TYPE,
    IS_CHANGED)
  Values
   (docId, display_order, NULL, 'List of Documents', 'List of Documents',
    'Y', NULL, NULL, getContractDocuments(p_contractNo), NULL,
    NULL, 'N', 'N', 'N', 'FULL',  'N');


END;
/
