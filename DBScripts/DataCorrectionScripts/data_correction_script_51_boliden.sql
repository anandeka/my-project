SET DEFINE OFF;
Insert into DPU_DERIVATIVE_PRICE_UNIT
   (DERIVATIVE_PRICE_UNIT_ID, INSTRUMENT_PRICING_ID, PRICE_UNIT_ID, VERSION, IS_DELETED)
 Values
   ('DPU-435-BK-END', 'DIP-156', 'PUM-283', '62845', 'N');

Insert into DPU_DERIVATIVE_PRICE_UNIT
   (DERIVATIVE_PRICE_UNIT_ID, INSTRUMENT_PRICING_ID, PRICE_UNIT_ID, VERSION, IS_DELETED)
 Values
   ('DPU-435-BK-END1', 'DIP-157', 'PUM-283', '62845', 'N');

COMMIT;
update DPU_DERIVATIVE_PRICE_UNIT dpu
    set DPU.INSTRUMENT_PRICING_ID = 'DIP-156' where DPU.INSTRUMENT_PRICING_ID = 'DIP-158';
update DIP_DER_INSTRUMENT_PRICING dip
    set DIP.IS_DELETED = 'Y' where DIP.INSTRUMENT_PRICING_ID = 'DIP-158';
update DIPAP_DER_INS_PRICING_AP dipap  
set DIPAP.IS_DELETED = 'Y' where dipap.INSTRUMENT_PRICING_ID = 'DIP-158';
commit;