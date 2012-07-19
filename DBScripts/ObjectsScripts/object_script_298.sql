
ALTER TABLE asm_assay_sublot_mapping ADD dry_wet_qty_ratio NUMBER(25,10);

ALTER TABLE sam_stock_assay_mapping ADD  is_output_assay VARCHAR2(1) DEFAULT 'N';