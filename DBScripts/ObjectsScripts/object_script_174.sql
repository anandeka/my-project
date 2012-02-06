drop table acs_approval_config_setup;

CREATE TABLE acs_approval_config_setup(
  acs_id                VARCHAR2 (15 Char) primary key,
  entity_type           VARCHAR2(30 CHAR) NOT NULL ,
  approval          VARCHAR2(30 CHAR) NOT NULL ,
  isactive  CHAR(1 CHAR)            NOT NULL

);
CREATE TABLE aes_approval_event_setup(
  aes_id                VARCHAR2 (15 Char) primary key,
  acs_id                VARCHAR2 (15 Char) ,
  event_type           VARCHAR2(30 CHAR) NOT NULL 
 
);