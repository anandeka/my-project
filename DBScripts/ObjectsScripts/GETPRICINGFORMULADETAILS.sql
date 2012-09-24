CREATE OR REPLACE FUNCTION GETPRICINGFORMULADETAILS(p_pcbph_id VARCHAR2)
   RETURN VARCHAR2
IS
   formuladescription   VARCHAR2 (4000) := '';
BEGIN
   SELECT (CASE
              WHEN pcbpd.price_basis = 'Formula'
                 THEN    ppfh.formula_description
                      || ' - '
                      || (SELECT   stragg (   ps.price_source_name
                                           || ' '
                                           || pp.price_point_name
                                           || ' '
                                           || apm.available_price_display_name
                                          )
                              FROM dim_der_instrument_master dim,
                                   ppfd_phy_price_formula_details ppfd,
                                   pp_price_point pp,
                                   ps_price_source ps,
                                   apm_available_price_master apm
                             WHERE dim.instrument_id = ppfd.instrument_id
                               AND ppfd.is_active = 'Y'
                               AND ppfh.ppfh_id = ppfd.ppfh_id
                               AND ppfd.price_point_id = pp.price_point_id(+)
                               AND ppfd.price_source_id = ps.price_source_id
                               AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                          GROUP BY ppfh.ppfh_id)
              WHEN pcbpd.price_basis = 'Index'
                 THEN (SELECT    dim.instrument_name
                              || ' - '
                              || ps.price_source_name
                              || ' '
                              || pp.price_point_name
                              || ' '
                              || apm.available_price_display_name
                         FROM dim_der_instrument_master dim,
                              ppfd_phy_price_formula_details ppfd,
                              pp_price_point pp,
                              ps_price_source ps,
                              apm_available_price_master apm
                        WHERE dim.instrument_id = ppfd.instrument_id
                          AND ppfd.is_active = 'Y'
                          AND ppfh.ppfh_id = ppfd.ppfh_id
                          AND ppfd.price_point_id = pp.price_point_id(+)
                          AND ppfd.price_source_id = ps.price_source_id
                          AND ppfd.available_price_type_id =
                                                        apm.available_price_id)
              ELSE ''
           END
          )
     INTO formuladescription
     FROM pcbpd_pc_base_price_detail pcbpd,
          pcbph_pc_base_price_header pcbph,
          ppfh_phy_price_formula_header ppfh
    WHERE pcbph.pcbph_id = pcbpd.pcbph_id
      AND pcbpd.pcbpd_id = ppfh.pcbpd_id
      AND pcbpd.is_active = 'Y'
      AND ppfh.is_active = 'Y'
      AND pcbpd.pcbph_id = p_pcbph_id;

   RETURN formuladescription;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      formuladescription := '';
      RETURN formuladescription;
END;
/
