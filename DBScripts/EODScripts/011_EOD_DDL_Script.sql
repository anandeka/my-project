create table dithul_di_treatment_header_ul
(
  dithul_id               varchar2(15),
  internal_action_ref_no  varchar2(15),
  entry_type              varchar2(30),
  dith_id                 varchar2(15),
  pcdi_id                 varchar2(15),
  pcth_id                 varchar2(15),
  version                 number(10),
  is_active               char(1),
  dbd_id                  varchar2(15)
);

create table dirhul_di_refining_header_ul
(
  dirhul_id               varchar2(15),
  internal_action_ref_no  varchar2(15),
  entry_type              varchar2(30),
  dirh_id                 varchar2(15),
  pcdi_id                 varchar2(15),
  pcrh_id                 varchar2(15),
  version                 number(10),
  is_active               char(1),
  dbd_id                  varchar2(15)
);

create table diphul_di_penalty_header_ul
(
  diphul_id               varchar2(15),
  internal_action_ref_no  varchar2(15),
  entry_type              varchar2(30),
  diph_id                 varchar2(15),
  pcdi_id                 varchar2(15),
  pcaph_id                varchar2(15),
  version                 number(10),
  is_active               char(1),
  dbd_id                  varchar2(15)
);


create table dith_di_treatment_header
(
  dith_id		varchar2(15),
  pcdi_id		varchar2(15),
  pcth_id		varchar2(15),
  version		number(10),
  is_active		char(1)  default 'Y',
  dbd_id		varchar2(15),
  process_id		varchar2(15)   
);


create table dirh_di_refining_header
(
  dirh_id		varchar2(15),
  pcdi_id		varchar2(15),
  pcrh_id		varchar2(15),
  version		number(10),
  is_active		char(1) default 'Y',
  dbd_id		varchar2(15),
  process_id		varchar2(15)
);


create table diph_di_penalty_header
(
  diph_id		varchar2(15) ,
  pcdi_id		varchar2(15) ,
  pcaph_id		varchar2(15) ,
  version		number(10),
  is_active		char(1) default 'Y',
  dbd_id                varchar2(15),
  process_id		varchar2(15)
);