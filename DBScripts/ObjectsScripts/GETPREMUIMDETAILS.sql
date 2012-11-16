CREATE OR REPLACE FUNCTION "GETPREMUIMDETAILS" (pcdiid NUMBER)
   RETURN VARCHAR2
IS
   CURSOR cr_incotermpremium
   IS
      SELECT (itm.incoterm || ': ' || pcdb.premium || ' '
              || pum.price_unit_name
             ) premium
        FROM pci_physical_contract_item pci,
             pcdb_pc_delivery_basis pcdb,
             pcdi_pc_delivery_item pcdi,
             ppu_product_price_units ppu,
             pum_price_unit_master pum,
             itm_incoterm_master itm
       WHERE pci.is_called_off = 'Y'
         AND pci.is_active = 'Y'
         AND pcdi.pcdi_id = pci.pcdi_id
         AND pcdi.internal_contract_ref_no = pcdb.internal_contract_ref_no
         AND pcdb.pcdb_id = pci.pcdb_id
         AND pcdb.premium IS NOT NULL
         AND pcdb.is_active = 'Y'
         AND pcdi.is_active = 'Y'
         AND pcdb.premium_unit_id = ppu.internal_price_unit_id
         AND ppu.price_unit_id = pum.price_unit_id
         AND ppu.is_active = 'Y'
         AND ppu.is_deleted = 'N'
         AND pum.is_active = 'Y'
         AND pum.is_deleted = 'N'
         AND itm.incoterm_id = pcdb.inco_term_id
         AND itm.is_active = 'Y'
         AND itm.is_deleted = 'N'
         AND pci.pcdi_id = pcdiid;

   CURSOR cr_qualitypremium
   IS
      SELECT DISTINCT (   pcpdqd.quality_name
                       || ':- '
                       || pcqpd.premium_disc_value
                       || ' '
                       || pum.price_unit_name
                      ) qualitypremium
                 FROM pci_physical_contract_item pci,
                      pcqpd_pc_qual_premium_discount pcqpd,
                      pcpdqd_pd_quality_details pcpdqd,
                      ppu_product_price_units ppu,
                      pum_price_unit_master pum
                WHERE pci.is_called_off = 'Y'
                  AND pci.is_active = 'Y'
                  AND pcpdqd.pcqpd_id = pcqpd.pcqpd_id
                  AND pcpdqd.pcpq_id = pci.pcpq_id
                  AND pcqpd.premium_disc_unit_id = ppu.internal_price_unit_id
                  AND ppu.price_unit_id = pum.price_unit_id
                  AND ppu.is_active = 'Y'
                  AND ppu.is_deleted = 'N'
                  AND pum.is_active = 'Y'
                  AND pum.is_deleted = 'N'
                  AND pci.pcdi_id = pcdiid;

   incoterm_premium   VARCHAR2 (500)  := '';
   quality_premium    VARCHAR2 (500)  := '';
   premium_details    VARCHAR2 (1000) := '';
BEGIN
   FOR cr_premium_rec IN cr_incotermpremium
   LOOP
      IF incoterm_premium IS NULL
      THEN
         incoterm_premium := 'INCO-Term Premium:- ' || cr_premium_rec.premium;
      ELSE
         incoterm_premium :=
                           incoterm_premium || ', ' || cr_premium_rec.premium;
      END IF;
   END LOOP;

   FOR cr_qualitypremium_rec IN cr_qualitypremium
   LOOP
      IF quality_premium IS NULL
      THEN
         quality_premium :=
                 'Quality Premium:- ' || cr_qualitypremium_rec.qualitypremium;
      ELSE
         quality_premium :=
              quality_premium || ', ' || cr_qualitypremium_rec.qualitypremium;
      END IF;
   END LOOP;

   IF incoterm_premium IS NOT NULL AND quality_premium IS NOT NULL
   THEN
      premium_details := incoterm_premium || CHR (10) || quality_premium;
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
