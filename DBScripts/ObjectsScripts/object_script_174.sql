drop table acs_approval_config_setup;

CREATE TABLE acs_approval_config_setup(
  entity_type           VARCHAR2(30 CHAR) NOT NULL ,
  approval          VARCHAR2(30 CHAR) NOT NULL ,
  isactive  CHAR(1 CHAR)            NOT NULL

);
