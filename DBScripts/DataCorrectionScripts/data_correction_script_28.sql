update POCD_PRICE_OPTION_CALLOFF_DTLS pocd
set POCD.FX_CONVERSION_METHOD = (select PFFXD.FX_CONVERSION_METHOD
                                 from PCBPD_PC_BASE_PRICE_DETAIL pcbpd,PFFXD_PHY_FORMULA_FX_DETAILS pffxd
                                 where PFFXD.PFFXD_ID =PCBPD.PFFXD_ID
                                 and PCBPD.PCBPD_ID = POCD.PCBPD_ID)
   where POCD.FX_CONVERSION_METHOD  is null;    