ALTER TABLE URM_UMPIRE_RULE_MASTER
 DROP PRIMARY KEY CASCADE;
DROP TABLE URM_UMPIRE_RULE_MASTER CASCADE CONSTRAINTS;

CREATE TABLE URM_UMPIRE_RULE_MASTER
(
  URM_ID        VARCHAR2(15 BYTE)               NOT NULL,
  RULE_DESC     VARCHAR2(4000 BYTE)             NOT NULL,
  RULE_FORMULA  CLOB                            NOT NULL,
  IS_ACTIVE     CHAR(1 BYTE)                    DEFAULT 'Y'                   NOT NULL,
  VERSION       NUMBER(10)                      NOT NULL,
  RULE_NAME     VARCHAR2(50 BYTE)               NOT NULL
);

COMMENT ON TABLE URM_UMPIRE_RULE_MASTER IS 'This table stores the umpiring rules';

COMMENT ON COLUMN URM_UMPIRE_RULE_MASTER.URM_ID IS 'Unique Id for each rule';

COMMENT ON COLUMN URM_UMPIRE_RULE_MASTER.RULE_DESC IS 'rule description e.g. Should the umpire assay fail between the result of the two parties, the arithmatical mean of the umpire assay
and the assay of the party which is the nearer to that of the umpire shall be taken as the agreed assay';


CREATE UNIQUE INDEX PK_URM ON URM_UMPIRE_RULE_MASTER
(URM_ID);


ALTER TABLE URM_UMPIRE_RULE_MASTER ADD (
  CONSTRAINT PK_URM
 PRIMARY KEY
 (URM_ID)
    USING INDEX 
    );

