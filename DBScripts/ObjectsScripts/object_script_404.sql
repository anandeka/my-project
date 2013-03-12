ALTER TABLE pcm_physical_contract_main
 ADD (deal_type  VARCHAR2(30 CHAR));

ALTER TABLE pcm_physical_contract_main
 ADD (is_self_billing  CHAR(1 CHAR)                 DEFAULT 'N');


ALTER  TABLE pcmul_phy_contract_main_ul ADD (deal_type  VARCHAR2(30 CHAR));

ALTER TABLE PCMUL_PHY_CONTRACT_MAIN_UL
 ADD (is_self_billing  CHAR(1 CHAR)                 DEFAULT 'N');



SET DEFINE OFF;
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Long Term', 'Long Term');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Spot', 'Spot');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Swap', 'Swap');
Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('Trader Frame', 'Trader Frame');


SET DEFINE OFF;
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DealType', 'Long Term', 'N', 3);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DealType', 'Spot', 'N', 1);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DealType', 'Swap', 'N', 2);
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('DealType', 'Trader Frame', 'N', 4);

