-- New Cloumns Added  
ALTER TABLE sdd_d ADD (supp_rep VARCHAR2 (65),mode_of_transport VARCHAR2 (15));
ALTER TABLE sad_d ADD (supp_rep VARCHAR2 (65),mode_of_transport VARCHAR2 (15));

--New Table For Contractual Assay(Payable) Population At GMR Level And Provisinal Assay At Stock Level For All Element
CREATE TABLE sddassay_d(

  internal_doc_ref_no       VARCHAR2(30),
  internal_gmr_ref_no       VARCHAR2(15),
  internal_stock_id         VARCHAR2 (15),
  stock_ref_no              VARCHAR2 (30),
  element_id                VARCHAR2 (15),
  element_name              VARCHAR2 (30),
  typical                   NUMBER (25,10),
  unit_of_measure           VARCHAR2 (15),
  ratio_name                VARCHAR2 (50),
  assay_type                VARCHAR2 (50),
  net_weight	            VARCHAR2 (25),
  dry_weight                VARCHAR2 (25),
  qty_unit_name             VARCHAR2 (30)

);

--New Table For Phyical Attribute Population At Stock Level For Documnet 
CREATE TABLE sddpqpa_d(

  internal_doc_ref_no       VARCHAR2(30),
  internal_gmr_ref_no       VARCHAR2(15),
  internal_grd_ref_no       VARCHAR2 (15),
  stock_ref_no              VARCHAR2 (30),
  attribute_id              VARCHAR2 (15),
  attribute_name            VARCHAR2 (30),
  attribute_value           VARCHAR2 (100)
);
