ALTER TABLE pqca_pq_chemical_attributes ADD (
  CONSTRAINT fk_pqca_unit_of_measure  FOREIGN KEY (unit_of_measure)
    REFERENCES rm_ratio_master (ratio_id));


ALTER TABLE sam_stock_assay_mapping ADD(
            CONSTRAINT fk_sam_internal_grd_ref_no FOREIGN KEY(internal_grd_ref_no) REFERENCES grd_goods_record_detail(internal_grd_ref_no),
            CONSTRAINT fk_sam_ash_id FOREIGN KEY(ash_id) REFERENCES ash_assay_header(ash_id));