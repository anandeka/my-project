CREATE OR REPLACE FUNCTION "GETQUALITYLOCATIONPREMUIM" (
   pcdiid   NUMBER
)
   RETURN VARCHAR2
IS
   CURSOR cr_incotermpremium
   IS
      SELECT (CASE
                 WHEN pcdb.premium IS NULL
                    THEN ''
                 ELSE    itm.incoterm
                      || ' - '
                      || cim.city_name
                      || ' , '
                      || pcdb.premium
                      || ' '
                      || pum.price_unit_name
                      || ' ,Fx : '
                      || pffxd.fixed_fx_rate
              END
             ) premium
        FROM pcdb_pc_delivery_basis pcdb,
             itm_incoterm_master itm,
             cim_citymaster cim,
             pcdiob_di_optional_basis pcdiob,
             ppu_product_price_units ppu,
             pum_price_unit_master pum,
             pffxd_phy_formula_fx_details pffxd
       WHERE pcdb.inco_term_id = itm.incoterm_id
         AND pcdb.city_id = cim.city_id
         AND pcdiob.pcdb_id = pcdb.pcdb_id
         AND pcdb.premium_unit_id = ppu.internal_price_unit_id
         AND ppu.price_unit_id = pum.price_unit_id
         AND pffxd.pffxd_id = pcdb.pffxd_id
         AND pffxd.is_active = 'Y'
         AND pcdb.is_active = 'Y'
         AND pcdiob.is_active = 'Y'
         AND pcdiob.pcdi_id = pcdiid;
         --AND pcdb.internal_contract_ref_no = p_internal_contract_ref_no;

   CURSOR cr_qualitypremium
   IS
      SELECT DISTINCT (   pcpdqd.quality_name
                       || ', '
                       || pcqpd.premium_disc_name
                       || ' : '
                       || pcqpd.premium_disc_value
                       || ' '
                       || pum.price_unit_name
                       || ' ,Fx : '
                       || pffxd.fixed_fx_rate
                      ) qualitypremium
                 FROM pcqpd_pc_qual_premium_discount pcqpd,
                      pcpdqd_pd_quality_details pcpdqd,
                      ppu_product_price_units ppu,
                      pum_price_unit_master pum,
                      pffxd_phy_formula_fx_details pffxd,
                      pcdiqd_di_quality_details pcdiqd
                WHERE pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                  AND pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id
                  AND ppu.price_unit_id = pum.price_unit_id
                  AND pffxd.pffxd_id = pcqpd.pffxd_id
                  AND pcqpd.is_active = 'Y'
                  AND pcpdqd.is_active = 'Y'
                  AND pffxd.is_active = 'Y'
                  --AND pcqpd.internal_contract_ref_no =
                  --                                  p_internal_contract_ref_no;
                  AND pcdiqd.is_active ='Y'
                  AND pcdiqd.pcdi_id = pcdiid
                  AND pcdiqd.pcpq_id = pcpdqd.pcpq_id;

   quality_premium    VARCHAR2 (500)  := '';
   incoterm_premium   VARCHAR2 (500)  := '';
   premium_details    VARCHAR2 (1000) := '';
BEGIN
   FOR cr_premium_rec IN cr_incotermpremium
   LOOP
      IF incoterm_premium IS NULL
      THEN
         incoterm_premium :=
                   'Location Premium : ' || CHR (10)
                   || cr_premium_rec.premium;
      ELSE
         incoterm_premium :=
                        incoterm_premium || CHR (10)
                        || cr_premium_rec.premium;
      END IF;
   END LOOP;

   FOR cr_qualitypremium_rec IN cr_qualitypremium
   LOOP
      IF quality_premium IS NULL
      THEN
         quality_premium :=
               'Quality Premium : '
            || CHR (10)
            || cr_qualitypremium_rec.qualitypremium;
      ELSE
         quality_premium :=
            quality_premium || CHR (10)
            || cr_qualitypremium_rec.qualitypremium;
      END IF;
   END LOOP;

   IF incoterm_premium IS NOT NULL AND quality_premium IS NOT NULL
   THEN
      premium_details := quality_premium || CHR (10) || incoterm_premium;
   END IF;

   IF incoterm_premium IS NOT NULL AND quality_premium IS NULL
   THEN
      premium_details := incoterm_premium;
   END IF;

   IF incoterm_premium IS NULL AND quality_premium IS NOT NULL
   THEN
      premium_details := quality_premium;
   END IF;

   RETURN premium_details;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      premium_details := '';
      RETURN premium_details;
END;
/
