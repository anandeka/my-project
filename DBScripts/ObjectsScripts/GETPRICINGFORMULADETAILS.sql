CREATE OR REPLACE FUNCTION GETPRICINGFORMULADETAILS(p_pcbph_id VARCHAR2)
   RETURN VARCHAR2
IS
   formuladescription   VARCHAR2 (4000) := '';
   qtytobepriced        VARCHAR2 (100)  := '';
   market               VARCHAR2 (4000) := '';
   quotationalperiod    VARCHAR2 (4000) := '';
   fx                   VARCHAR2 (4000) := '';
   fixedprice            VARCHAR2 (100)  := '';
  
  cursor cr_price_detail_id is
   SELECT pcbpd.pcbpd_id as pcbpdid,
          PCBPD.PRICE_BASIS as pricebasis
     FROM pcbpd_pc_base_price_detail pcbpd
    WHERE pcbpd.pcbph_id = p_pcbph_id
      AND pcbpd.is_active = 'Y';
BEGIN
    
FOR price_detail_cur IN cr_price_detail_id
      LOOP
    BEGIN
        SELECT 'Quantity: ' || pcbpd.qty_to_be_priced || '% of the finally agreed content'
            INTO qtytobepriced
            FROM pcbpd_pc_base_price_detail pcbpd
            WHERE pcbpd.pcbpd_id = price_detail_cur.pcbpdid
            AND pcbpd.is_active = 'Y';
    END;
    
    formuladescription:= formuladescription || qtytobepriced || CHR(10);
    
    if(price_detail_cur.pricebasis = 'Fixed')
    then
       BEGIN
        SELECT 'Price: ' || PCBPD.PRICE_VALUE || ' ' || PUM.PRICE_UNIT_NAME
            INTO fixedprice
            FROM pcbpd_pc_base_price_detail pcbpd,
                 ppu_product_price_units ppu,
                 pum_price_unit_master pum
            WHERE pcbpd.pcbpd_id = price_detail_cur.pcbpdid
            AND pcbpd.price_unit_id = ppu.internal_price_unit_id(+)
            AND ppu.price_unit_id = pum.price_unit_id(+)
            AND pcbpd.is_active = 'Y';
        END;
        
       
        formuladescription:= formuladescription || fixedprice || chr(10);
        else 
   
        
    begin 
        SELECT 'Market: ' || (CASE
           WHEN pcbpd.price_basis = 'Formula' OR pcbpd.price_basis = 'Index'
              THEN (CASE
                       WHEN pcbpd.price_basis = 'Index'
                          THEN (SELECT    dim.instrument_name
                                       || ' - '
                                       || ps.price_source_name
                                       || ', '
                                       || pp.price_point_name
                                       || ', '
                                       || apm.available_price_display_name
                                  FROM ppfh_phy_price_formula_header ppfh,
                                       ppfd_phy_price_formula_details ppfd,
                                       dim_der_instrument_master dim,
                                       pp_price_point pp,
                                       ps_price_source ps,
                                       apm_available_price_master apm
                                 WHERE ppfh.pcbpd_id = price_detail_cur.pcbpdid
                                   AND ppfh.ppfh_id = ppfd.ppfh_id
                                   AND dim.instrument_id = ppfd.instrument_id
                                   AND ppfd.price_point_id = pp.price_point_id(+)
                                   AND ppfd.price_source_id =
                                                            ps.price_source_id
                                   AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                                   AND ppfh.is_active = 'Y'
                                   AND ppfd.is_active = 'Y'
                                   AND dim.is_active = 'Y'
                                   AND dim.is_deleted = 'N'
                                   AND pp.is_active = 'Y'
                                   AND pp.is_deleted = 'N'
                                   AND ps.is_active = 'Y'
                                   AND ps.is_deleted = 'N'
                                   AND apm.is_active = 'Y'
                                   AND apm.is_deleted = 'N')
                       WHEN pcbpd.price_basis = 'Formula'
                          THEN (SELECT ppfh.formula_name || ': '|| stragg
                                             (   ps.price_source_name
                                              || ' '
                                              || pp.price_point_name
                                              || ' '
                                              || apm.available_price_display_name
                                             )
                                  FROM ppfh_phy_price_formula_header ppfh,
                                       dim_der_instrument_master dim,
                                       ppfd_phy_price_formula_details ppfd,
                                       pp_price_point pp,
                                       ps_price_source ps,
                                       apm_available_price_master apm
                                 WHERE ppfh.pcbpd_id = price_detail_cur.pcbpdid
                                   AND dim.instrument_id = ppfd.instrument_id
                                   AND ppfd.is_active = 'Y'
                                   AND ppfh.ppfh_id = ppfd.ppfh_id
                                   AND ppfd.price_point_id = pp.price_point_id(+)
                                   AND ppfd.price_source_id =
                                                            ps.price_source_id
                                   AND ppfd.available_price_type_id =
                                                        apm.available_price_id
                                   AND PPFH.IS_ACTIVE='Y'
                                   AND DIM.IS_ACTIVE='Y'
                                   AND DIM.IS_DELETED='N'
                                   AND PP.IS_ACTIVE='Y'
                                   AND PP.IS_DELETED='N'
                                   and PS.IS_ACTIVE='Y'
                                   and PS.IS_DELETED='N'
                                   and APM.IS_ACTIVE='Y'
                                   and APM.IS_DELETED='N'
                                   group by PPFH.FORMULA_NAME)
                    END
                   )
        END
       ) into market
    FROM pcbpd_pc_base_price_detail pcbpd
    WHERE pcbpd.pcbpd_id = price_detail_cur.pcbpdid
     AND pcbpd.is_active = 'Y';
     end;
   
   formuladescription:= formuladescription || market || chr(10);
      
     begin
      SELECT 'Quotational Period: ' || (CASE
           WHEN pcbpd.price_basis = 'Formula' OR pcbpd.price_basis = 'Index'
              THEN    pfqpp.qp_pricing_period_type
                   || ', '
                   || (CASE
                          WHEN pfqpp.qp_pricing_period_type = 'Month'
                             THEN pfqpp.qp_month || '-' || pfqpp.qp_year
                          WHEN pfqpp.qp_pricing_period_type = 'Date'
                             THEN TO_CHAR (pfqpp.qp_date, 'dd-Mon-yyyy')
                          WHEN pfqpp.qp_pricing_period_type = 'Period'
                             THEN    TO_CHAR (pfqpp.qp_period_from_date,
                                              'dd-Mon-yyyy'
                                             )
                                  || ' to '
                                  || TO_CHAR (pfqpp.qp_period_to_date,
                                              'dd-Mon-yyyy'
                                             )
                          WHEN pfqpp.qp_pricing_period_type = 'Event'
                             THEN    pfqpp.no_of_event_months
                                  || ' '
                                  || pfqpp.event_name
                                  || ' '
                                  || pfqpp.qp_pricing_type
                       END
                      )
                   || (CASE
                          WHEN pfqpp.is_qp_any_day_basis = 'Y'
                             THEN ', Any Day'
                       END
                      )
                   || (CASE
                          WHEN pfqpp.is_spot_pricing = 'Y'
                             THEN ', Spot'
                       END)
        END
       ) into quotationalperiod
  FROM pcbpd_pc_base_price_detail pcbpd,
       pfqpp_phy_formula_qp_pricing pfqpp,
       ppfh_phy_price_formula_header ppfh
 WHERE pfqpp.ppfh_id = ppfh.ppfh_id
   AND ppfh.pcbpd_id = pcbpd.pcbpd_id
   AND pcbpd.pcbpd_id = price_detail_cur.pcbpdid
   AND pfqpp.is_active = 'Y'
   and pcbpd.is_active='Y'
   and ppfh.is_active='Y';
    end;
    
    formuladescription:= formuladescription || quotationalperiod || chr(10);
    end if;
    SELECT    'Fx: '
       || (CASE
              WHEN pffxd.fx_rate_type = 'Fixed'
                 THEN TO_CHAR (pffxd.fixed_fx_rate)
              WHEN pffxd.fx_rate_type = 'Variable'
                 THEN (SELECT    pdm.product_desc
                              || ', '
                              || ps.price_source_name
                              || ' '
                              || pffxd.off_day_price
                         FROM pdm_productmaster pdm, ps_price_source ps
                        WHERE pffxd.currency_pair_instrument = pdm.product_id
                          AND pffxd.price_source_id = ps.price_source_id)
           END
          )
       || (CASE
              WHEN pffxd.fx_conversion_method IS NOT NULL
                 THEN ', ' || pffxd.fx_conversion_method
           END
          ) into fx
  FROM pcbpd_pc_base_price_detail pcbpd,
       ppfh_phy_price_formula_header ppfh,
       pffxd_phy_formula_fx_details pffxd,
       ppu_product_price_units ppu,
       pum_price_unit_master pum
 WHERE pcbpd.pcbpd_id = ppfh.pcbpd_id(+)
   AND pcbpd.price_unit_id = ppu.internal_price_unit_id(+)
   AND ppu.price_unit_id = pum.price_unit_id(+)
   AND pcbpd.pffxd_id = pffxd.pffxd_id
   AND pffxd.is_active = 'Y'
   AND pcbpd.is_active = 'Y'
   AND ppfh.is_active(+) = 'Y'
   AND pcbpd.pcbpd_id = price_detail_cur.pcbpdid;
   
   formuladescription:= formuladescription || fx || chr(10);
    
 end loop;

   /*SELECT stragg((CASE
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
          ))
     INTO formuladescription
     FROM pcbpd_pc_base_price_detail pcbpd,
          pcbph_pc_base_price_header pcbph,
          ppfh_phy_price_formula_header ppfh
    WHERE pcbph.pcbph_id = pcbpd.pcbph_id
      AND pcbpd.pcbpd_id = ppfh.pcbpd_id
      AND pcbpd.is_active = 'Y'
      AND ppfh.is_active = 'Y'
      AND pcbpd.pcbph_id = p_pcbph_id;*/

   RETURN formuladescription;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      formuladescription := '';
      RETURN formuladescription;
END;
/
