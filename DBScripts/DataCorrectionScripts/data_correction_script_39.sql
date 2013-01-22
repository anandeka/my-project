UPDATE pcmac_pcm_addn_charges pcmac
   SET pcmac.is_automatic_charge = 'Y'
 WHERE pcmac.addn_charge_name IN
          ('Sampling Charge', 'Handling Charge', 'Location Value',
           'Freight Allowance')
   AND pcmac.is_active = 'Y';