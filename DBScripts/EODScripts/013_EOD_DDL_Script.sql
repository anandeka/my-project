create table cipql_ctrt_itm_payable_qty_log
(
  cipq_id                        varchar2(15),
  internal_action_ref_no         varchar2(15),
  entry_type                     varchar2(30),
  internal_contract_item_ref_no  varchar2(15),
  element_id                     varchar2(15),
  payable_qty_delta              number(25,10),
  qty_unit_id                    varchar2(15),
  version                        number(10),
  is_active                      char(1),
  dbd_id		         varchar2(15)
);


create table dipql_del_itm_payble_qty_log
(
  dipq_id                       varchar2(15),
  internal_action_ref_no        varchar2(15),
  entry_type                    varchar2(30),
  pcdi_id                       varchar2(15),
  element_id                    varchar2(15),
  payable_qty_delta             number(25,10),
  qty_unit_id                   varchar2(15),
  price_option_call_off_status  varchar2(30),
  version                       number(10),
  is_active                     char(1),
  is_price_optionality_present  char(1),
  dbd_id		        varchar2(15)
);



create table spql_stock_payable_qty_log
(
  spq_id                varchar2(15),
  internal_action_ref_no varchar2(15),
  entry_type             varchar2(30),
  internal_gmr_ref_no   varchar2(15),
  action_no             number(2),
  stock_type            char(1),
  internal_grd_ref_no   varchar2(15),
  internal_dgrd_ref_no  varchar2(15),
  element_id            varchar2(15),
  payable_qty_delta     number(25,10),
  qty_unit_id           varchar2(15),
  version               number(10),
  is_active             char(1),
  dbd_id		varchar2(15) 
);



create table cipq_contract_item_payable_qty
(
  cipq_id                        varchar2(15),
  internal_contract_item_ref_no  varchar2(15),
  element_id                     varchar2(15),
  payable_qty                    number(25,10),
  qty_unit_id                    varchar2(15),
  version                        number(10),
  is_active                      char(1) default 'Y',
  dbd_id                         varchar2(15),
  process_id		         varchar2(15)
);


create table dipq_delivery_item_payable_qty
(
  dipq_id                       varchar2(15),
  pcdi_id                       varchar2(15),
  element_id                    varchar2(15),
  payable_qty                   number(25,10),
  qty_unit_id                   varchar2(15),
  price_option_call_off_status  varchar2(30),
  version                       number(10),
  is_active                     char(1) default 'Y',
  is_price_optionality_present  char(1),
  dbd_id                        varchar2(15),
  process_id		        varchar2(15)
);


create table spq_stock_payable_qty
(
  spq_id			varchar2(15),
  internal_gmr_ref_no		varchar2(15),
  action_no			number(2),
  stock_type			char(1),
  internal_grd_ref_no		varchar2(15),
  internal_dgrd_ref_no		varchar2(15),
  element_id			varchar2(15),
  payable_qty			number(25,10),
  qty_unit_id			varchar2(15),
  version			number(10),
  is_active			char(1)  default 'Y',
  dbd_id                        varchar2(15),
  process_id		        varchar2(15)
);

