CREATE OR REPLACE FUNCTION "GETOUTPUTQUALITYDETAILS" (c_pcpd_id VARCHAR2)
   RETURN VARCHAR2
IS
   CURSOR cr_quality
   IS
      SELECT qat.quality_name AS quality_details,
             (CASE
                 WHEN pcpq.assay_header_id IS NOT NULL
                    THEN getchemicalattributes (pcpq.assay_header_id)
              END
             ) chem_attr,
             (CASE
                 WHEN pcpq.phy_attribute_group_no IS NOT NULL
                    THEN getphysicalattributes (pcpq.phy_attribute_group_no)
              END
             ) phy_attr
        FROM pcpq_pc_product_quality pcpq,
             pcpd_pc_product_definition pcpd,
             qat_quality_attributes qat
       WHERE pcpq.quality_template_id = qat.quality_id
         AND pcpd.pcpd_id = pcpq.pcpd_id
         AND pcpq.is_active = 'Y'
         AND pcpd.pcpd_id = c_pcpd_id;

   qualitydescription   VARCHAR2 (2000) := '';
   i                    NUMBER (5)      := 1;
   
BEGIN
   FOR quality_rec IN cr_quality
   LOOP
   
      qualitydescription :=
            qualitydescription ||  'Quality '
         || i
         || ': '
         || quality_rec.quality_details || CHR(10) ;
   
      
      IF (quality_rec.chem_attr IS NOT NULL)
      THEN
         qualitydescription :=
               qualitydescription
            || 'Chemical Composition :'
            || CHR (10)
            || quality_rec.chem_attr;
      END IF;

      IF (quality_rec.phy_attr IS NOT NULL)
      THEN
         qualitydescription :=
               qualitydescription
            || 'Physical Specifications :'
            || CHR (10)
            || quality_rec.phy_attr;
      END IF;
      
      i := i+1;
      
   END LOOP;

   RETURN qualitydescription;
END;
/
