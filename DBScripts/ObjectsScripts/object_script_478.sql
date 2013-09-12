CREATE TABLE gmrqp_quota_period_d
(
  internal_doc_ref_no       VARCHAR2(30),
  doc_issue_date            VARCHAR2(30),
  internal_gmr_ref_no       VARCHAR2(15),
  gmr_ref_no                VARCHAR2(30),
  cp_id                     VARCHAR2 (20),
  cp_name                   VARCHAR2(65),
  cp_address                VARCHAR2(1000),
  product_id                VARCHAR2 (15),
  product_name              VARCHAR2 (200),
  vessel_voyage_name        VARCHAR2(100),
  senders_ref_no            VARCHAR2(50),
  bl_date                   VARCHAR2 (30),
  bl_quantity               NUMBER (25,10),
  gmr_unit                  VARCHAR2(15),
  landing_date              VARCHAR2(30),
  prov_payment_due_date     VARCHAR2 (30),
  payment_term_id           VARCHAR2 (15),
  payment_term              VARCHAR2 (50),
  user_firstname            VARCHAR2 (50),
  user_lastname             VARCHAR2 (50)
 );
CREATE TABLE gmrqpc_child_qp_d(

  internal_doc_ref_no       VARCHAR2(30),
  internal_gmr_ref_no       VARCHAR2(15),
  element_id                VARCHAR2 (15),
  element_name              VARCHAR2 (30),
  quota_period              VARCHAR2 (50),
  event_name                VARCHAR2 (100)
);