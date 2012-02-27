CREATE OR REPLACE FUNCTION "GETOUTPUTPRODUCTDETAILS" (
   p_contractno   VARCHAR2
)
   RETURN VARCHAR2
IS
   CURSOR cr_output_products
   IS
      SELECT pcpd.pcpd_id AS pcpd_id, pdm.product_desc AS productdesc
        FROM pcpd_pc_product_definition pcpd, pdm_productmaster pdm
       WHERE pcpd.product_id = pdm.product_id
         AND pcpd.input_output = 'Output'
         AND pcpd.internal_contract_ref_no = p_contractno;

   productdescription   VARCHAR2 (4000) := '';
   i                           NUMBER (5)      := 1;
BEGIN
   FOR product_rec IN cr_output_products
   LOOP
      productdescription := productdescription || 'Product: '
         || i
         || CHR (10)
         || product_rec.productdesc;
      productdescription :=
            productdescription
         || CHR (10)
         || getoutputqualitydetails (product_rec.pcpd_id);
      i := i + 1;
   END LOOP;

   RETURN productdescription;
END;
/
