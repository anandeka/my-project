create table pcpchul_payble_contnt_headr_ul
(
  pcpchul_id                varchar2(15) not null,
  internal_action_ref_no    varchar2(15) not null,
  entry_type                varchar2(30) not null,
  pcpch_id                  varchar2(15) not null,
  internal_contract_ref_no  varchar2(15) not null,
  range_type                varchar2(20),
  range_unit_id             varchar2(15) not null,
  element_id                varchar2(15) not null,
  slab_tier                 varchar2(15),
  version                   number(10)   not null,
  is_active                 char(1)      not null,
  dbd_id                    varchar2(15)
);




create table pqdul_payable_quality_dtl_ul
(
  pqdul_id                varchar2(15) not null,
  internal_action_ref_no  varchar2(15) not null,
  entry_type              varchar2(30) not null,
  pqd_id                  varchar2(15) not null,
  pcpch_id                varchar2(15) not null,
  pcpq_id                 varchar2(15) not null,
  version                 number(10)   not null,
  is_active               char(1)      not null,
  dbd_id                  varchar2(15)
);


create table pcepcul_elem_payble_content_ul
(
  pcepcul_id               varchar2(15)  not null,
  internal_action_ref_no   varchar2(15)  not null,
  entry_type               varchar2(30)  not null,
  pcepc_id                 varchar2(15)  not null,
  range_min_op             varchar2(2),
  range_min_value          varchar2(15),
  range_max_op             varchar2(2),
  range_max_value          varchar2(15),
  payable_formula_id       varchar2(15),
  payable_content_value    varchar2(15),
  payable_content_unit_id  varchar2(15),
  assay_deduction          varchar2(15),
  assay_deduction_unit_id  varchar2(15),
  include_ref_charges      char(1),
  refining_charge_value    varchar2(15),
  refining_charge_unit_id  varchar2(15),
  version                  number(10)      not null,
  is_active                char(1)         not null,
  pcpch_id                 varchar2(15)    not null,
  position                 varchar2(30),
  dbd_id                   varchar2(15)
);


create table pcthul_treatment_header_ul
(
  pcthul_id                 varchar2(15)   not null,
  internal_action_ref_no    varchar2(15)   not null,
  entry_type                varchar2(30)   not null,
  pcth_id                   varchar2(15)   not null,
  internal_contract_ref_no  varchar2(15)   not null,
  range_type                varchar2(20)   not null,
  range_unit_id             varchar2(15),
  price_unit_id             varchar2(15),
  slab_tier                 varchar2(15),
  version                   number(10)     not null,
  is_active                 char(1)        not null,
  dbd_id                    varchar2(15)
);

create table tedul_treatment_element_dtl_ul
(
  tedul_id                varchar2(15)     not null,
  internal_action_ref_no  varchar2(15)     not null,
  entry_type              varchar2(30)     not null,
  ted_id                  varchar2(15)     not null,
  pcth_id                 varchar2(15)     not null,
  element_id              varchar2(15)     not null,
  version                 number(10)       not null,
  is_active               char(1)          not null,
  dbd_id                  varchar2(15)
);


create table tqdul_treatment_quality_dtl_ul
(
  tqdul_id                varchar2(15)     not null,
  internal_action_ref_no  varchar2(15)     not null,
  entry_type              varchar2(30)     not null,
  tqd_id                  varchar2(15)     not null,
  pcth_id                 varchar2(15)     not null,
  pcpq_id                 varchar2(15)     not null,
  version                 number(10)       not null,
  is_active               char(1)          not null,
  dbd_id                  varchar2(15)
);


create table pcetcul_elem_treatmnt_chrg_ul
(
  pcetcul_id                varchar2(15)   not null,
  internal_action_ref_no    varchar2(15)   not null,
  entry_type                varchar2(30)   not null,
  pcetc_id                  varchar2(15)   not null,
  pcth_id                   varchar2(15)   not null,
  range_min_op              varchar2(2),
  range_min_value           varchar2(15),
  range_max_op              varchar2(2),
  range_max_value           varchar2(15),
  position                  varchar2(30),
  treatment_charge          varchar2(15),
  treatment_charge_unit_id  varchar2(15),
  weight_type               varchar2(20),
  charge_basis              varchar2(20),
  esc_desc_value            varchar2(15),
  esc_desc_unit_id          varchar2(15),
  version                   number(10)     not null,
  is_active                 char(1)        not null,
  charge_type               varchar2(15),
  dbd_id                    varchar2(15)
);

create table pcarul_assaying_rules_ul
(
  pcarul_id                 varchar2(15)   not null,
  internal_action_ref_no    varchar2(15)   not null,
  entry_type                varchar2(30)   not null,
  pcar_id                   varchar2(15)   not null,
  internal_contract_ref_no  varchar2(15)   not null,
  element_id                varchar2(15),
  final_assay_basis_id      varchar2(20),
  comparision               varchar2(30),
  split_limit_basis         varchar2(30),
  split_limit               varchar2(15),
  split_limit_unit_id       varchar2(15),
  version                   number(10)     not null,
  is_active                 char(1)        not null,
  dbd_id                    varchar2(15)
);


create table pcaeslul_assay_elm_splt_lmt_ul
(
  pcaeslul_id             varchar2(15)     not null,
  internal_action_ref_no  varchar2(15)     not null,
  entry_type              varchar2(30)     not null,
  pcaesl_id               varchar2(15)     not null,
  pcar_id                 varchar2(15)     not null,
  assay_min_op            varchar2(2),
  assay_min_value         varchar2(15),
  assay_max_op            varchar2(2)      not null,
  assay_max_value         varchar2(15),
  applicable_value        varchar2(15),
  version                 number(10)       not null,
  is_active               char(1)          not null,
  dbd_id                  varchar2(15)
);

create table arqdul_assay_quality_dtl_ul
(
  arqdul_id               varchar2(15)     not null,
  internal_action_ref_no  varchar2(15)     not null,
  entry_type              varchar2(30)     not null,
  arqd_id                 varchar2(15)     not null,
  pcar_id                 varchar2(15)     not null,
  pcpq_id                 varchar2(15)     not null,
  version                 number(10)       not null,
  is_active               char(1)          not null,
  dbd_id                  varchar2(15)
);


create table pcaphul_attr_penalty_header_ul
(
  pcaphul_id                varchar2(15)   not null,
  internal_action_ref_no    varchar2(15)   not null,
  entry_type                varchar2(30)   not null,
  pcaph_id                  varchar2(15)   not null,
  internal_contract_ref_no  varchar2(15)   not null,
  attribute_type            varchar2(20),
  range_unit_id             varchar2(15)   not null,
  slab_tier                 varchar2(15)   not null,
  version                   number(10)     not null,
  is_active                 char(1)        not null,
  dbd_id                    varchar2(15)
);


create table pcapul_attribute_penalty_ul
(
  pcapul_id                 varchar2(15)   not null,
  internal_action_ref_no    varchar2(15)   not null,
  entry_type                varchar2(30)   not null,
  pcap_id                   varchar2(15)   not null,
  range_min_op              varchar2(2),
  range_min_value           varchar2(15),
  range_max_op              varchar2(2),
  range_max_value           varchar2(15),
  penalty_charge_type       varchar2(20),
  penalty_basis             varchar2(15),
  penalty_amount            varchar2(15),
  penalty_unit_id           varchar2(15),
  penalty_weight_type       varchar2(20),
  per_increase_value        varchar2(15),
  per_increase_unit_id      varchar2(15),
  deducted_payable_element  varchar2(15),
  deducted_payable_value    varchar2(15),
  deducted_payable_unit_id  varchar2(15),
  charge_basis              varchar2(20),
  version                   number(10)     not null,
  is_active                 char(1) default 'Y'  not null,
  pcaph_id                  varchar2(15)   not null,
  position                  varchar2(30),
  dbd_id                    varchar2(15)
);


create table pqdul_penalty_quality_dtl_ul
(
  pqdul_id                varchar2(15)     not null,
  internal_action_ref_no  varchar2(15)     not null,
  entry_type              varchar2(30)     not null,
  pqd_id                  varchar2(15)     not null,
  pcaph_id                varchar2(15)     not null,
  pcpq_id                 varchar2(15)     not null,
  version                 number(10)       not null,
  is_active               char(1)          not null,
  dbd_id                  varchar2(15)
);


create table padul_penalty_attribute_dtl_ul
(
  padul_id                varchar2(15)     not null,
  internal_action_ref_no  varchar2(15)     not null,
  entry_type              varchar2(30)     not null,
  pad_id                  varchar2(15)     not null,
  pcaph_id                varchar2(15)     not null,
  element_id              varchar2(15)     not null,
  pqpa_id                 varchar2(15),
  version                 number(10)       not null,
  is_active               char(1)          not null,
  dbd_id                  varchar2(15)
);


create table pcrhul_refining_header_ul
(
  pcrhul_id                 varchar2(15)   not null,
  internal_action_ref_no    varchar2(15)   not null,
  entry_type                varchar2(30)   not null,
  pcrh_id                   varchar2(15)   not null,
  internal_contract_ref_no  varchar2(15)   not null,
  range_type                varchar2(20)   not null,
  range_unit_id             varchar2(15),
  price_unit_id             varchar2(15),
  slab_tier                 varchar2(15),
  version                   number(10)     not null,
  is_active                 char(1)        not null,
  dbd_id                    varchar2(15)
);


create table rqdul_refining_quality_dtl_ul
(
  rqdul_id                varchar2(15)     not null,
  internal_action_ref_no  varchar2(15)     not null,
  entry_type              varchar2(30)     not null,
  rqd_id                  varchar2(15)     not null,
  pcrh_id                 varchar2(15)     not null,
  pcpq_id                 varchar2(15)     not null,
  version                 number(10)       not null,
  is_active               char(1)          not null,
  dbd_id                  varchar2(15)
);


create table redul_refining_element_dtl_ul
(
  redul_id                varchar2(15)     not null,
  internal_action_ref_no  varchar2(15)     not null,
  entry_type              varchar2(30)     not null,
  red_id                  varchar2(15)     not null,
  pcrh_id                 varchar2(15)     not null,
  element_id              varchar2(15)     not null,
  version                 number(10)       not null,
  is_active               char(1)          not null,
  dbd_id                  varchar2(15)
);


create table pcercul_elem_refing_charge_ul
(
  pcercul_id               varchar2(15)    not null,
  internal_action_ref_no   varchar2(15)    not null,
  entry_type               varchar2(30)    not null,
  pcerc_id                 varchar2(15)    not null,
  pcrh_id                  varchar2(15)    not null,
  range_min_op             varchar2(2),
  range_min_value          varchar2(15),
  range_max_op             varchar2(2),
  range_max_value          varchar2(15),
  charge_type              varchar2(15),
  position                 varchar2(30),
  refining_charge          varchar2(15),
  refining_charge_unit_id  varchar2(15),
  weight_type              varchar2(20),
  charge_basis             varchar2(20),
  esc_desc_value           varchar2(15),
  esc_desc_unit_id         varchar2(15),
  version                  number(10)      not null,
  is_active                char(1)         not null,
  dbd_id                   varchar2(15)
);

create table pcpch_pc_payble_content_header
(
  pcpch_id                  varchar2(15) not null,
  internal_contract_ref_no  varchar2(15) not null,
  range_type                varchar2(20),
  range_unit_id             varchar2(15) not null,
  element_id                varchar2(15) not null,
  slab_tier                 varchar2(15) not null,
  version                   number(10)   not null,
  is_active                 char(1)      default 'Y'  not null,
  dbd_id                    varchar2(15),
  process_id                varchar2(15)
);


create table pqd_payable_quality_details
(
  pqd_id     varchar2(15) not null,
  pcpch_id   varchar2(15) not null,
  pcpq_id    varchar2(15) not null,
  version    number(10)   not null,
  is_active  char(1)     default 'Y'  not null,
  dbd_id     varchar2(15),
  process_id varchar2(15)
);


create table pcepc_pc_elem_payable_content
(
  pcepc_id                 varchar2(15)    not null,
  range_min_op             varchar2(2),
  range_min_value          number(10,4),
  range_max_op             varchar2(2),
  range_max_value          number(10,4),
  payable_formula_id       varchar2(15),
  payable_content_value    number(10,4),
  payable_content_unit_id  varchar2(15),
  assay_deduction          number(10,4),
  assay_deduction_unit_id  varchar2(15),
  include_ref_charges      char(1),
  refining_charge_value    number(10,4),
  refining_charge_unit_id  varchar2(15),
  version                  number(10)   not null,
  is_active                char(1)   default 'Y'  not null,
  pcpch_id                 varchar2(15) not null,
  position                 varchar2(30),
  dbd_id                    varchar2(15),
  process_id                varchar2(15)
);


create table pcth_pc_treatment_header
(
  pcth_id                   varchar2(15)   not null,
  internal_contract_ref_no  varchar2(15)   not null,
  range_type                varchar2(20)   not null,
  range_unit_id             varchar2(15),
  price_unit_id             varchar2(15),
  slab_tier                 varchar2(15),
  version                   number(10)     not null,
  is_active                 char(1) default 'Y' not null,
  dbd_id                    varchar2(15),
  process_id                varchar2(15)
);


create table ted_treatment_element_details
(
  ted_id		    varchar2(15)  not null,
  pcth_id                   varchar2(15)  not null,
  element_id                varchar2(15)  not null,
  version                   number(10)    not null,
  is_active                 char(1)  default 'Y' not null,
  dbd_id                    varchar2(15),
  process_id                varchar2(15)  
);

create table tqd_treatment_quality_details
(
  tqd_id	            varchar2(15)  not null,
  pcth_id		    varchar2(15)  not null,
  pcpq_id                   varchar2(15)  not null,
  version                   number(10)    not null,
  is_active                 char(1) default 'Y' not null,
  dbd_id                    varchar2(15),
  process_id                varchar2(15)
);

create table pcetc_pc_elem_treatment_charge
(
  pcetc_id                  varchar2(15)   not null,
  pcth_id                   varchar2(15)   not null,
  range_min_op              varchar2(2),
  range_min_value           number(10,4),
  range_max_op              varchar2(2),
  range_max_value           number(10,4),
  charge_type               varchar2(15),
  position                  varchar2(30),
  treatment_charge          number(10,4),
  treatment_charge_unit_id  varchar2(15),
  weight_type               varchar2(20),
  charge_basis              varchar2(20),
  esc_desc_value            number(10,4),
  esc_desc_unit_id          varchar2(15),
  version                   number(10)     not null,
  is_active                 char(1) default 'Y' not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);


create table pcar_pc_assaying_rules
(
  pcar_id                   varchar2(15)   not null,
  internal_contract_ref_no  varchar2(15)   not null,
  element_id                varchar2(15),
  final_assay_basis_id      varchar2(20),
  comparision               varchar2(30),
  split_limit_basis         varchar2(30),
  split_limit               number(10,4),
  split_limit_unit_id       varchar2(15),
  version                   number(10)     not null,
  is_active                 char(1)        not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);

create table pcaesl_assay_elem_split_limits
(
  pcaesl_id                 varchar2(15)  not null,
  pcar_id                   varchar2(15)  not null,
  assay_min_op              varchar2(2),
  assay_min_value           number(10,4),
  assay_max_op              varchar2(2)   not null,
  assay_max_value	    number(10,4),
  applicable_value	    number(10,4),
  version                   number(10)   not null,
  is_active                 char(1)      not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);

create table arqd_assay_quality_details
(
  arqd_id		    varchar2(15)  not null,
  pcar_id		    varchar2(15)  not null,
  pcpq_id		    varchar2(15)  not null,
  version		    number(10)    not null,
  is_active		     char(1)  default 'Y'  not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);

create table pcaph_pc_attr_penalty_header
(
  pcaph_id                  varchar2(15)   not null,
  internal_contract_ref_no  varchar2(15)   not null,
  attribute_type            varchar2(20),
  range_unit_id             varchar2(15)   not null,
  slab_tier                 varchar2(15)   not null,
  version                   number(10)     not null,
  is_active                 char(1) default 'Y' not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);


create table pcap_pc_attribute_penalty
(
  pcap_id                   varchar2(15)   not null,
  range_min_op              varchar2(2),
  range_min_value           number(10,4),
  range_max_op              varchar2(2),
  range_max_value           number(10,4),
  penalty_charge_type       varchar2(20),
  penalty_basis             varchar2(15),
  penalty_amount            number(10,4),
  penalty_unit_id           varchar2(15),
  penalty_weight_type       varchar2(20),
  per_increase_value        number(10,4),
  per_increase_unit_id      varchar2(15),
  deducted_payable_element  varchar2(15),
  deducted_payable_value    number(10,4),
  deducted_payable_unit_id  varchar2(15),
  charge_basis              varchar2(20),
  version                   number(10)      not null,
  is_active                 char(1) default 'Y'  not null,
  pcaph_id                  varchar2(15)   not null,
  position                  varchar2(30),
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);


create table pqd_penalty_quality_details
(
  pqd_id                    varchar2(15) not null,
  pcaph_id                  varchar2(15) not null,
  pcpq_id                   varchar2(15) not null,
  version                   number(10)   not null,
  is_active                 char(1)  default 'Y'  not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);


create table pad_penalty_attribute_details
(
  pad_id		    varchar2(15) not null,
  pcaph_id                  varchar2(15) not null,
  element_id                varchar2(15) not null,
  pqpa_id                   varchar2(15),
  version                   number(10)  not null,
  is_active                 char(1)  default 'Y'  not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);

create table pcrh_pc_refining_header
(
  pcrh_id                   varchar2(15)   not null,
  internal_contract_ref_no  varchar2(15)   not null,
  range_type                varchar2(20)   not null,
  range_unit_id             varchar2(15),
  price_unit_id             varchar2(15),
  slab_tier                 varchar2(15),
  version                   number(10)     not null,
  is_active                 char(1) default 'Y'  not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);


create table rqd_refining_quality_details
(
  rqd_id                    varchar2(15)  not null,
  pcrh_id                   varchar2(15)  not null,
  pcpq_id                   varchar2(15)  not null,
  version		    number(10)    not null,
  is_active		    char(1)  default 'y'  not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);


create table red_refining_element_details
(
  red_id                    varchar2(15) not null,
  pcrh_id                   varchar2(15) not null,
  element_id                varchar2(15) not null,
  version                   number(10)   not null,
  is_active	            char(1)  default 'y' not null,
  dbd_id     	            varchar2(15),
  process_id                varchar2(15)
);

create table pcerc_pc_elem_refining_charge
(
  pcerc_id                 varchar2(15)  not null,
  pcrh_id                  varchar2(15)  not null,
  range_min_op             varchar2(2),
  range_min_value          number(10,4),
  range_max_op             varchar2(2),
  range_max_value          number(10,4),
  charge_type              varchar2(15),
  position                 varchar2(30),
  refining_charge          number(10,4),
  refining_charge_unit_id  varchar2(15),
  weight_type              varchar2(20),
  charge_basis             varchar2(20),
  esc_desc_value           number(10,4),
  esc_desc_unit_id         varchar2(15),
  version                  number(10)   not null,
  is_active                char(1)  default 'y' not null,
  dbd_id     	           varchar2(15),
  process_id               varchar2(15)
);
-------EOD TABLES

ALTER TABLE tmpc_temp_m2m_pre_check ADD (conc_product_id  VARCHAR2(15), 
conc_quality_id VARCHAR2(15),
product_type     VARCHAR2(20), 
element_id      VARCHAR2(15),
element_name   VARCHAR2(50),
assay_header_id  varchar2(20));


alter table md_m2m_daily add ( conc_product_id   varchar2(20),
                            conc_quality_id     varchar2(20),
                            element_id                varchar2(20),
                            product_type            varchar2(20),
                            treatment_charge                   number(25,5),
                            refine_charge                   number(25,5),
                            penalty_charge                   number(25,5));

create table cipde_cipd_element_price
(
  corporate_id                    varchar2(15),
  process_id                      varchar2(20),  
  pcdi_id                         varchar2(15),
  internal_contract_item_ref_no   varchar2(15),
  internal_contract_ref_no        varchar2(15),
  contract_ref_no                 varchar2(30),
  delivery_item_no                number(5),  
  element_id                      varchar2(15),
  assay_qty                       number(10),
  assay_qty_unit_id               varchar2(15),
  payable_qty                     number(10),
  payable_qty_unit_id             varchar2(15),  
  contract_price                  number(25,5),
  price_unit_id                   varchar2(15),
  price_unit_cur_id               varchar2(15),
  price_unit_cur_code             varchar2(15),
  price_unit_weight               number(7,2),
  price_unit_weight_unit_id       varchar2(15),
  price_unit_weight_unit          varchar2(15),
  fixed_qty                       number(15),
  unfixed_qty                     number(15),
  price_basis                     varchar2(30),-- fixed,index,formula
  price_fixation_status           varchar2(50), -- fixed,not fixed,partially fixed,fully fixed,finalized
  price_fixation_details          varchar2(1000), -- 
  payment_due_date                date,-- is null store eod date
  contract_base_price_unit_id     varchar2(15),
  contract_to_base_fx_rate        number,
  price_description               varchar2(500),
  qp_period_from_date             date,
  qp_period_to_date               date,
  instrument_id                   varchar2(15),
  refining_charge                 number(10),
  treatment_charge                number(10),
  penalty_charge                  number(10),
  cur_id                          varchar2(10),
  cur_code                        varchar2(15)
);



create table ceqs_contract_ele_qty_status(
  process_id                      varchar2(15),
  corporate_id                    varchar2(15),
  internal_contract_item_ref_no   varchar2(15),
  element_id                      varchar2(15),
  assay_qty                       number(25,5),
  assay_qty_unit_id               varchar2(15),
  payable_qty                     number(25,5),
  payable_qty_unit_id             varchar2(15),
  assay_percentage                number(25,5),
  assay_percentage_unit_id        varchar2(15),
  dbd_id                          varchar2(15)
  ); 


create table POUED_ELEMENT_DETAILS
(
  CORPORATE_ID                   VARCHAR2(15),
  CORPORATE_NAME                 VARCHAR2(100),
  PROCESS_ID                     VARCHAR2(15),
  MD_ID                          VARCHAR2(15),
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15),
  ELEMENT_ID                     VARCHAR2(15),
  ELEMENT_NAME                   VARCHAR2(15),
  ASSAY_HEADER_ID                VARCHAR2(15),
  ASSAY_QTY                      NUMBER(35,5),
  ASSAY_QTY_UNIT_ID              VARCHAR2(15),
  PAYABLE_QTY                    NUMBER(35,5),
  PAYABLE_QTY_UNIT_ID            VARCHAR2(15),
  REFINING_CHARGE                NUMBER(35,5),
  TREATMENT_CHARGE               NUMBER(35,5),
  PENALTY_CHARGE                 NUMBER(35,5),
  PRICING_DETAILS                VARCHAR2(200),
  CONTRACT_PRICE                 NUMBER(35,5),
  PRICE_UNIT_ID                  VARCHAR2(15),
  PRICE_UNIT_CUR_ID              VARCHAR2(15),
  PRICE_UNIT_CUR_CODE            VARCHAR2(15),
  PRICE_UNIT_WEIGHT_UNIT_ID      VARCHAR2(15),
  PRICE_UNIT_WEIGHT              NUMBER(7,2),
  PRICE_UNIT_WEIGHT_UNIT         VARCHAR2(15),
  M2M_PRICE                      NUMBER(35,5),
  M2M_PRICE_UNIT_ID              VARCHAR2(15),
  M2M_PRICE_CUR_ID               VARCHAR2(15),
  M2M_PRICE_CUR_CODE             VARCHAR2(15),
  M2M_PRICE_WEIGHT               NUMBER(7,2),
  M2M_PRICE_WEGHT_UNIT_ID        VARCHAR2(15),
  M2M_PRICE_WEIGHT_UNIT          VARCHAR2(15),
  CONTRACT_VALUE                 NUMBER(35,5),
  CONTRACT_VALUE_CUR_ID          VARCHAR2(15),
  CONTRACT_VALUE_CUR_CODE        VARCHAR2(15),
  CONTRACT_VALUE_IN_BASE         NUMBER(35,5),
  CONTRACT_PREMIUM_VALUE_IN_BASE NUMBER(35,5),
  M2M_VALUE                      NUMBER(35,5),
  M2M_VALUE_CUR_ID               VARCHAR2(15),
  M2M_VALUE_CUR_CODE             VARCHAR2(15),
  M2M_REFINING_CHARGE            NUMBER(35,5),
  M2M_TREATMENT_CHARGE           NUMBER(35,5),
  M2M_PENALTY_CHARGE             NUMBER(35,5),
  M2M_LOC_DIFF                   NUMBER(35,5),
  M2M_AMT_IN_BASE                NUMBER(35,5),
  SC_IN_BASE_CUR                 NUMBER(35,5),
  VALUATION_DR_ID                VARCHAR2(15),
  VALUATION_DR_ID_NAME           VARCHAR2(30),
  VALUATION_MONTH                VARCHAR2(20),
  VALUATION_DATE                 DATE,
  EXPECTED_COG_NET_SALE_VALUE    NUMBER(35,5),
  UNREALIZED_PNL_IN_BASE_CUR     NUMBER(35,5),
  BASE_CUR_ID                    VARCHAR2(15),
  BASE_CUR_CODE                  VARCHAR2(15),
  PRICE_CUR_TO_BASE_CUR_FX_RATE  NUMBER(15,8),
  M2M_CUR_TO_BASE_CUR_FX_RATE    NUMBER(15,8),
  DERIVATIVE_DEF_ID              VARCHAR2(15),
  VALUATION_EXCHANGE_ID          VARCHAR2(15),
  VALUATION_EXCHANGE             VARCHAR2(50)
);
create table POUE_PHY_OPEN_UNREAL_ELEMENT
(
  CORPORATE_ID                   VARCHAR2(15),
  CORPORATE_NAME                 VARCHAR2(100),
  PROCESS_ID                     VARCHAR2(15),
  PCDI_ID                        VARCHAR2(15),
  DELIVERY_ITEM_NO               VARCHAR2(20),
  PREFIX                         VARCHAR2(10),
  MIDDLE_NO                      VARCHAR2(15),
  SUFFIX                         VARCHAR2(15),
  INTERNAL_CONTRACT_REF_NO       VARCHAR2(15),
  CONTRACT_REF_NO                VARCHAR2(30),
  CONTRACT_ISSUE_DATE            DATE,
  INTERNAL_CONTRACT_ITEM_REF_NO  VARCHAR2(15),
  BASIS_TYPE                     VARCHAR2(20),
  DELIVERY_PERIOD_TYPE           VARCHAR2(15),
  DELIVERY_FROM_MONTH            VARCHAR2(15),
  DELIVERY_FROM_YEAR             VARCHAR2(15),
  DELIVERY_TO_MONTH              VARCHAR2(15),
  DELIVERY_TO_YEAR               VARCHAR2(15),
  DELIVERY_FROM_DATE             DATE,
  DELIVERY_TO_DATE               DATE,
  TRANSIT_DAYS                   NUMBER(10),
  CONTRACT_TYPE                  VARCHAR2(1),
  APPROVAL_STATUS                VARCHAR2(100),
  UNREALIZED_TYPE                VARCHAR2(100),
  PROFIT_CENTER_ID               VARCHAR2(15),
  PROFIT_CENTER_NAME             VARCHAR2(50),
  PROFIT_CENTER_SHORT_NAME       VARCHAR2(15),
  CP_PROFILE_ID                  VARCHAR2(15),
  CP_NAME                        VARCHAR2(100),
  TRADE_USER_ID                  VARCHAR2(15),
  TRADE_USER_NAME                VARCHAR2(50),
  PRODUCT_ID                     VARCHAR2(15),
  PRODUCT_NAME                   VARCHAR2(200),
  ITEM_DRY_QTY                   NUMBER(20,5),
  ITEM_WET_QTY                   NUMBER(20,5),
  QTY_UNIT_ID                    VARCHAR2(15),
  QTY_UNIT                       VARCHAR2(15),
  QUALITY_ID                     VARCHAR2(15),
  QUALITY_NAME                   VARCHAR2(50),
  FIXATION_METHOD                VARCHAR2(30),
  PRICE_STRING                   VARCHAR2(500),
  PRICE_FIXATION_STATUS          VARCHAR2(20),
  PRICE_FIXATION_DETAILS         VARCHAR2(500),
  ITEM_DELIVERY_PERIOD_STRING    VARCHAR2(500),
  INCOTERM_ID                    VARCHAR2(15),
  INCOTERM                       VARCHAR2(15),
  ORIGINATION_CITY_ID            VARCHAR2(15),
  ORIGINATION_CITY               VARCHAR2(50),
  ORIGINATION_COUNTRY_ID         VARCHAR2(15),
  ORIGINATION_COUNTRY            VARCHAR2(50),
  DESTINATION_CITY_ID            VARCHAR2(15),
  DESTINATION_CITY               VARCHAR2(50),
  DESTINATION_COUNTRY_ID         VARCHAR2(15),
  DESTINATION_COUNTRY            VARCHAR2(50),
  ORIGINATION_REGION_ID          VARCHAR2(15),
  ORIGINATION_REGION             VARCHAR2(50),
  DESTINATION_REGION_ID          VARCHAR2(15),
  DESTINATION_REGION             VARCHAR2(50),
  PAYMENT_TERM_ID                VARCHAR2(15),
  PAYMENT_TERM                   VARCHAR2(50),
  CONTRACT_PRICE_STRING          VARCHAR2(500),
  CONTRACT_RC_TC_PEN_STRING      VARCHAR2(500),
  M2M_PRICE_STRING               VARCHAR2(500),
  M2M_RC_TC_PEN_STRING           VARCHAR2(500),
  NET_CONTRACT_VALUE_IN_BASE_CUR NUMBER(35,5),
  NET_CONTRACT_PREM_IN_BASE_CUR  NUMBER(35,5),
  NET_M2M_AMT_IN_BASE_CUR        NUMBER(35,5),
  NET_SC_IN_BASE_CUR             NUMBER(35,5),
  EXPECTED_COG_NET_SALE_VALUE    NUMBER(35,5),
  UNREALIZED_PNL_IN_BASE_CUR     NUMBER(35,5),
  UNREAL_PNL_IN_BASE_PER_UNIT    NUMBER(35,5),
  PREV_DAY_UNR_PNL_IN_BASE_CUR   NUMBER(35,5),
  TRADE_DAY_PNL_IN_BASE_CUR      NUMBER(35,5),
  BASE_CUR_ID                    VARCHAR2(15),
  BASE_CUR_CODE                  VARCHAR2(15),
  GROUP_ID                       VARCHAR2(15),
  GROUP_NAME                     VARCHAR2(50),
  GROUP_CUR_ID                   VARCHAR2(15),
  GROUP_CUR_CODE                 VARCHAR2(10),
  GROUP_QTY_UNIT_ID              VARCHAR2(15),
  GROUP_QTY_UNIT                 VARCHAR2(15),
  BASE_QTY_UNIT_ID               VARCHAR2(15),
  BASE_QTY_UNIT                  VARCHAR2(15),
  CONT_UNR_STATUS                VARCHAR2(20),
  QTY_IN_BASE_UNIT               NUMBER(35,5),
  PROCESS_TRADE_DATE             DATE,
  STRATEGY_ID                    VARCHAR2(15),
  STRATEGY_NAME                  VARCHAR2(30)
);