
ALTER TABLE wns_assay_d_gmr ADD(qty_unit VARCHAR2(15));

ALTER TABLE wns_assay_d_gmr MODIFY(buyer VARCHAR2(50),seller VARCHAR2(50),container_no VARCHAR2(500),contract_type VARCHAR2(30),gmr_ref_no VARCHAR2(30),bl_no VARCHAR2(50),vessel_name VARCHAR2(100),senders_ref_no VARCHAR2(500));