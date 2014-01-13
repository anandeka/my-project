UPDATE gpad_gmr_price_alloc_dtls gpad
   SET gpad.is_fx_exposure_amount = 'N'
 WHERE gpad.is_fx_exposure_amount IS NULL AND gpad.is_active = 'Y';