DECLARE
   p_pcbpd_desc   VARCHAR2 (4000);

   CURSOR cr_pcbpdid_record
   IS
      SELECT pcbpd.pcbpd_id AS pcbpdid
        FROM pcbpd_pc_base_price_detail pcbpd
       WHERE pcbpd.description IS NULL AND pcbpd.is_active = 'Y';
BEGIN
   FOR cur_record_rows IN cr_pcbpdid_record
   LOOP
      DBMS_OUTPUT.put_line (' HII :' || cur_record_rows.pcbpdid);
      p_pcbpd_desc := getpricepointdescription (cur_record_rows.pcbpdid);

      IF p_pcbpd_desc IS NULL
      THEN
         DBMS_OUTPUT.put_line (' HI33 :' || cur_record_rows.pcbpdid);
      ELSE
         UPDATE pcbpd_pc_base_price_detail pcbpd
            SET pcbpd.description = p_pcbpd_desc
          WHERE pcbpd.pcbpd_id = cur_record_rows.pcbpdid;
      END IF;
   END LOOP;
END;
/


CREATE OR REPLACE FUNCTION GETPRICEPOINTDESCRIPTION(p_pcbpd_id VARCHAR2)
   RETURN VARCHAR2
IS
   pricepointdescription   CLOB := '';
BEGIN
SELECT ((CASE
          WHEN pcbpd.price_basis = 'Formula' or pcbpd.price_basis = 'Index' then
           (PCBPD.QTY_TO_BE_PRICED ||'% Quantity using ' || (case
          when pcbpd.price_basis = 'Formula' then
           ppfh.formula_description || ' - ' ||
           (SELECT stragg(ps.price_source_name || ' ' || pp.price_point_name || ' ' ||
                          apm.available_price_display_name)
              FROM dim_der_instrument_master      dim,
                   ppfd_phy_price_formula_details ppfd,
                   pp_price_point                 pp,
                   ps_price_source                ps,
                   apm_available_price_master     apm
             WHERE dim.instrument_id = ppfd.instrument_id
               AND ppfd.is_active = 'Y'
               AND ppfh.ppfh_id = ppfd.ppfh_id
               AND ppfd.price_point_id = pp.price_point_id(+)
               AND ppfd.price_source_id = ps.price_source_id
               AND ppfd.available_price_type_id = apm.available_price_id
             GROUP BY ppfh.ppfh_id)
        
          WHEN pcbpd.price_basis = 'Index' THEN
           (SELECT dim.instrument_name || ' - ' || ps.price_source_name || ' ' ||
                   pp.price_point_name || ' ' ||
                   apm.available_price_display_name
              FROM dim_der_instrument_master      dim,
                   ppfd_phy_price_formula_details ppfd,
                   pp_price_point                 pp,
                   ps_price_source                ps,
                   apm_available_price_master     apm
             WHERE dim.instrument_id = ppfd.instrument_id
               AND ppfd.is_active = 'Y'
               AND ppfh.ppfh_id = ppfd.ppfh_id
               AND ppfd.price_point_id = pp.price_point_id(+)
               AND ppfd.price_source_id = ps.price_source_id
               AND ppfd.available_price_type_id = apm.available_price_id)
        end) ||
       
        (select ', QP: ' || PFQPP.QP_PRICING_PERIOD_TYPE || ',' || (case
                  when PFQPP.QP_PRICING_PERIOD_TYPE = 'Month' then
                   PFQPP.QP_MONTH || '-' || PFQPP.QP_YEAR
                  when PFQPP.QP_PRICING_PERIOD_TYPE = 'Date' then
                   to_char(PFQPP.QP_DATE, 'dd-Mon-yyyy')
                  when PFQPP.QP_PRICING_PERIOD_TYPE = 'Period' then
                   to_char(PFQPP.QP_PERIOD_FROM_DATE, 'dd-Mon-yyyy') || ' to ' ||
                   to_char(PFQPP.QP_PERIOD_TO_DATE, 'dd-Mon-yyyy')
                  when PFQPP.QP_PRICING_PERIOD_TYPE = 'Event' then
                   PFQPP.NO_OF_EVENT_MONTHS || ' ' || PFQPP.EVENT_NAME || ' ' ||
                   PFQPP.QP_PRICING_TYPE
                end) || (case
                  when PFQPP.IS_QP_ANY_DAY_BASIS = 'Y' then
                   ',Is Any Day Basis : true'
                end)
           from PFQPP_PHY_FORMULA_QP_PRICING pfqpp
          where PFQPP.PPFH_ID = ppfh.ppfh_id
            and pfqpp.is_active = 'Y')) WHEN pcbpd.price_basis = 'Fixed' THEN
            (PCBPD.QTY_TO_BE_PRICED || '% Quantity, Price: ' || PCBPD.PRICE_VALUE || ' ' || PUM.PRICE_UNIT_NAME) END) || 
            (CASE
         WHEN PFFXD.FX_RATE_TYPE = 'Fixed' THEN
          ', Fx: ' || PFFXD.FIXED_FX_RATE
         WHEN PFFXD.FX_RATE_TYPE = 'Variable' THEN
          (select ', Fx: ' ||
                  PDM.PRODUCT_DESC || ' ' ||
                  PS.PRICE_SOURCE_NAME || ' ' ||
                  PFFXD.OFF_DAY_PRICE
             from PDM_PRODUCTMASTER pdm,
                  PS_PRICE_SOURCE   ps
            where PFFXD.CURRENCY_PAIR_INSTRUMENT =
                  PDM.PRODUCT_ID
              and PFFXD.PRICE_SOURCE_ID =
                  PS.PRICE_SOURCE_ID) END) || (CASE
         when PFFXD.FX_CONVERSION_METHOD is not null then
          ',' || PFFXD.FX_CONVERSION_METHOD
       END)) into pricepointdescription
  FROM pcbpd_pc_base_price_detail    pcbpd,
       ppfh_phy_price_formula_header ppfh,
       PFFXD_PHY_FORMULA_FX_DETAILS  pffxd,
       PPU_PRODUCT_PRICE_UNITS       ppu,
       PUM_PRICE_UNIT_MASTER         pum
 WHERE pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   and PCBPD.PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID(+)
   and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID(+)
   and PCBPD.PFFXD_ID = pffxd.pffxd_id
   and pffxd.is_active = 'Y'
   AND pcbpd.is_active = 'Y'
   AND ppfh.is_active(+) = 'Y'
   AND pcbpd.pcbpd_id = p_pcbpd_id ;
 
   RETURN pricepointdescription;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      pricepointdescription := '';
      RETURN pricepointdescription;
END;
/