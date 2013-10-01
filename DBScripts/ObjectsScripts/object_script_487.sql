

 drop table ASD_ASSAY_SAMPLE_D;
 create table ASD_ASSAY_SAMPLE_D
 (
   INTERNAL_DOC_REF_NO VARCHAR2(15),
   CORPORATE_ID        VARCHAR2(15),
   INTERNAL_GMR_REF_NO VARCHAR2(15),
   GMR_REF_NO          VARCHAR2(50),
   SENDERS_REF_NO      VARCHAR2(100),
   CONTRACT_REFNO      VARCHAR2(50),
   CP_REF_NO           VARCHAR2(100),
   CP_NAME             VARCHAR2(200),
   PRODUCT_NAME        VARCHAR2(500),
   VESSEL_VOYAGE_NAME  VARCHAR2(500),
   VOYAGE_NUMBER       VARCHAR2(200),
   SHIPPER_NAME        VARCHAR2(200),
   SHIPPERS_REF_NO     VARCHAR2(200),
   CONTAINER_NOS       VARCHAR2(500)
 );
 
 -- Create/Recreate indexes 
create index ASD_D1 on ASD_ASSAY_SAMPLE_D (internal_doc_ref_no, corporate_id);

--------------------------------------------------------------------------------------

CREATE SEQUENCE SEQDOC_SL
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;