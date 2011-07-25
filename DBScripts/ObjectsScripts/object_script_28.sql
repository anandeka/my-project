

CREATE TABLE DMD_DEAL_MANAGEMENT_DETAIL
(
  DEAL_DETAIL_ID  VARCHAR2(15 ),
  DEAL_ID         VARCHAR2(15 ),
  DEAL_TYPE       VARCHAR2(15 ),
  DEAL_TYPE_ID    VARCHAR2(15 )
);

ALTER TABLE DMD_DEAL_MANAGEMENT_DETAIL ADD (
  CONSTRAINT CHK_DMD_DEAL_TYPE
 CHECK (DEAL_TYPE IN ('Open','Invoice','Derivative')),
  CONSTRAINT PK_DMD
 PRIMARY KEY
 (DEAL_DETAIL_ID) );



CREATE TABLE DMS_DEAL_MANAGEMENT_SUMMARY
(
  DEAL_ID                 VARCHAR2(15 ),
  ACTIVITY_REF_NO         VARCHAR2(30 ),
  DEAL_REF_NO             VARCHAR2(30 ),
  ISSUE_DATE              DATE,
  DEAL_PURPOSE            VARCHAR2(200 ),
  DEAL_STAUTS             VARCHAR2(20 ),
  IS_DELETED              CHAR(1 )          DEFAULT 'N'                   NOT NULL,
  INTERNAL_ACTION_REF_NO  VARCHAR2(15 )     NOT NULL,
  CORPORATE_ID            VARCHAR2(15 )
);

ALTER TABLE DMS_DEAL_MANAGEMENT_SUMMARY ADD (
  CONSTRAINT CHK_DMS_IS_DELETED
 CHECK (IS_DELETED IN ('Y','N')),
  CONSTRAINT PK_DMS
 PRIMARY KEY
 (DEAL_ID));

ALTER TABLE DMS_DEAL_MANAGEMENT_SUMMARY ADD (
  CONSTRAINT FK_DMS_INTERNAL_ACTION_REF_NO 
 FOREIGN KEY (INTERNAL_ACTION_REF_NO) 
 REFERENCES AXS_ACTION_SUMMARY (INTERNAL_ACTION_REF_NO),
  CONSTRAINT FK_DMS_DEAL_STAUTS 
 FOREIGN KEY (DEAL_STAUTS) 
 REFERENCES SLV_STATIC_LIST_VALUE (VALUE_ID));





