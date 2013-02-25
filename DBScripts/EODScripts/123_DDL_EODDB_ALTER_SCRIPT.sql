create table pca_physical_contract_action(
 pca_id                    varchar2(15),                  
 internal_contract_ref_no  varchar2(15),                 
 internal_action_ref_no    varchar2(15),                
 version                   number(10),                
 is_active                 char(1),
 dbd_id                    varchar2(15),
 process_id                varchar2(15)
);


create table cod_call_off_details
(
  cod_id                        varchar2(15),
  contract_ref_no               varchar2(50),
  pcdi_id                       varchar2(15),
  internal_action_ref_no        varchar2(15),
  called_off_qty                number(25,10),
  unit_of_measure               varchar2(15),
  pcpq_id                       varchar2(15),
  quality_name                  varchar2(15),
  inco_term_location            varchar2(15),
  incoterm_id                   varchar2(15),
  internal_contract_item_ref_no varchar2(15),
  version                       number(10),
  is_active                     char(1),
  call_off_date                 date,
  dbd_id                        varchar2(15),
  process_id                    varchar2(15)
);


CREATE INDEX IDX_PCA_PROC_ID ON pca_physical_contract_action(PROCESS_ID);
CREATE INDEX IDX_COD_PROC_ID ON cod_call_off_details(PROCESS_ID);



