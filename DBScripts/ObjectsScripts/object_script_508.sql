
CREATE TABLE biod_blend_input_output_detail
(
  biod_id                           VARCHAR2(15)     NOT NULL,
  internal_action_ref_no            VARCHAR2(15)     NOT NULL,
  input_internal_gmr_no             VARCHAR2(15)     NOT NULL,
  input_gmr_ref_no                  VARCHAR2(30)     NOT NULL,
  input_stock_id                    VARCHAR2(15)     NOT NULL,
  input_stock_ref_no                VARCHAR2(30)     NOT NULL,
  input_stock_consumed_qty          NUMBER(25,10)    NOT NULL,
  input_stock_consumed_unit_id      VARCHAR2(15)     NOT NULL,
  output_internal_gmr_no            VARCHAR2(15)     NOT NULL,
  output_gmr_ref_no                 VARCHAR2(30)     NOT NULL,
  output_stock_id                   VARCHAR2(15)     NOT NULL,
  output_stock_ref_no               VARCHAR2(30)     NOT NULL,
  blended_qty                       NUMBER(25,10)    NOT NULL,
  blended_qty_unit_id               VARCHAR2(15)     NOT NULL,
  is_active                         CHAR(1)          DEFAULT 'Y'                   NOT NULL,
  corporate_id                      VARCHAR2(15)     NOT NULL
);

ALTER TABLE biod_blend_input_output_detail ADD (
  CONSTRAINT biod_pk
 PRIMARY KEY
 (biod_id));


ALTER  TABLE biod_blend_input_output_detail ADD (
  CONSTRAINT fk_action_ref_no
 FOREIGN KEY (internal_action_ref_no)
 REFERENCES axs_action_summary (internal_action_ref_no),
  CONSTRAINT fk_input_internal_gmr_no
 FOREIGN KEY (input_internal_gmr_no)
 REFERENCES gmr_goods_movement_record (internal_gmr_ref_no),
  CONSTRAINT fk_input_stock_id
 FOREIGN KEY (input_stock_id)
 REFERENCES grd_goods_record_detail (internal_grd_ref_no),
 CONSTRAINT fk_input_stock_unit_id
 FOREIGN KEY (input_stock_consumed_unit_id)
 REFERENCES qum_quantity_unit_master (qty_unit_id),
  CONSTRAINT fk_output_internal_gmr_no
 FOREIGN KEY (output_internal_gmr_no)
 REFERENCES gmr_goods_movement_record (internal_gmr_ref_no),
  CONSTRAINT fk_output_stock_id
 FOREIGN KEY (output_stock_id)
 REFERENCES grd_goods_record_detail (internal_grd_ref_no),
  CONSTRAINT fk_blended_qty_unit_id
 FOREIGN KEY (blended_qty_unit_id)
 REFERENCES qum_quantity_unit_master (qty_unit_id));

CREATE  SEQUENCE seq_biod
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;

-- GMR And GRD Consraints Changed Scripts 

ALTER TABLE gmr_goods_movement_record  DROP CONSTRAINT  chk_gmr_tolling_gmr_type;
ALTER TABLE gmr_goods_movement_record ADD (
  CONSTRAINT chk_gmr_tolling_gmr_type
 CHECK (tolling_gmr_type IN ('None Tolling','Mark For Tolling','Received Materials','Output Process',
                                'Process Activity','Input Process','Pledge','Financial Settlement',
                                'Return Material','Free Metal Utility','In Process Adjustment','Received Materials Mine','Blending')));

ALTER  TABLE agmr_action_gmr  DROP CONSTRAINT  chk_agmr_tolling_gmr_type;
ALTER  TABLE agmr_action_gmr ADD (
  CONSTRAINT chk_agmr_tolling_gmr_type
 CHECK (tolling_gmr_type IN ('None Tolling','Mark For Tolling','Received Materials','Output Process',
                                'Process Activity','Input Process','Pledge','Financial Settlement',
                                'Return Material','Free Metal Utility','In Process Adjustment','Received Materials Mine','Blending')));

ALTER TABLE grd_goods_record_detail  DROP CONSTRAINT  chk_grd_tolling_stock_type;
ALTER TABLE grd_goods_record_detail ADD (
  CONSTRAINT chk_grd_tolling_stock_type
 CHECK (tolling_stock_type IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock','Free Metal Utility Stock','In Process Adjustment Stock','RM Mining Stock','Blended Stock')));

ALTER  TABLE agrd_action_grd  DROP CONSTRAINT  chk_agrd_tolling_stock_type;
ALTER  TABLE agrd_action_grd ADD (
  CONSTRAINT chk_agrd_tolling_stock_type
 CHECK (tolling_stock_type IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock','Free Metal Utility Stock','In Process Adjustment Stock','RM Mining Stock','Blended Stock')));
									
			
	
CREATE TABLE ECSUL_ELEMENT_COST_STORE_UL
(
  ECSUL_ID                        VARCHAR2(15 CHAR),
  ELEMENT_COST_ID                 VARCHAR2(15 CHAR),
  INTERNAL_COST_ID                VARCHAR2(15 CHAR) NOT NULL,
  ELEMENT_ID                      VARCHAR2(15 CHAR) NOT NULL,
  ENTRY_TYPE                      VARCHAR2(30 CHAR),
  PAYABLE_QTY                     NUMBER(25,10),
  PAYABLE_QTY_IN_BASE_QTY_UNIT    NUMBER(25,10),
  QTY_UNIT_ID                     VARCHAR2(15 CHAR),
  COST_VALUE                      NUMBER(25,10),
  RATE_PRICE_UNIT_ID              VARCHAR2(15 CHAR),
  TRANSACTION_AMT                 NUMBER(25,10),
  TRANSACTION_AMT_CUR_ID          VARCHAR2(15 CHAR),
  FX_TO_BASE                      NUMBER(25,10),
  BASE_AMT                        NUMBER(25,10),
  BASE_AMT_CUR_ID                 VARCHAR2(15 CHAR),
  COST_IN_BASE_PRICE_UNIT_ID      NUMBER(25,10),
  COST_IN_TRANSACT_PRICE_UNIT_ID  NUMBER(25,10),
  VERSION                         NUMBER(10),
  IS_DELETED                      CHAR(1 CHAR),
  COST_REF_NO                     VARCHAR2(15 CHAR)
)

---- Sequence

CREATE SEQUENCE SEQ_ECSUL
  START WITH 715
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;



--------------------------------------------------------------


UPDATE gmc_grid_menu_configuration gmc
   SET gmc.FEATURE_ID = 'APP-PFL-N-225',
       gmc.link_called = 'function(){loadAllocateHedge();}',
       gmc.menu_parent_id = 'LOFE_1',
       gmc.acl_id = 'APP-ACL-N1402'
 WHERE gmc.menu_id = 'LOFE_2';



DROP TABLE FAD_FX_ALLOCATION_DETAILS;
 create table FAD_FX_ALLOCATION_DETAILS
 (
   FAD_ID                       VARCHAR2(15) not null,
   CORPORATE_ID                 VARCHAR2(15) not null,
   PRICE_FIXATION_ID            VARCHAR2(30)not null,
   INTERNAL_TREASURY_REF_NO     VARCHAR2(30) not null,  
   PFC_REF_NO                   VARCHAR2(50),  
   ALLOC_BASE_AMOUNT            NUMBER(35,10) default 0,
   ALLOC_FX_AMOUNT              NUMBER(35,10) default 0,
   BASE_CUR_ID                  VARCHAR2(15),
   FX_CUR_ID                    VARCHAR2(15),
   INTERNAL_ACTION_REF_NO       VARCHAR2(15),
   IS_ACTIVE                    CHAR(1) default 'Y',
   VERSION                      NUMBER(10)
 );

alter table FAD_FX_ALLOCATION_DETAILS add constraint PK_FAD primary key (FAD_ID);



CREATE SEQUENCE SEQ_FAD
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;


  -----------------------------------------------------------------------------------------------


  

alter table fad_fx_allocation_details add ACTIVITY_DATE varchar2(15);


-------------------------------------------------------------------------------------------------




ALTER  TABLE fad_fx_allocation_details
     ADD (trade_ref_no VARCHAR2 (30 CHAR),foreign_currency VARCHAR2 (15 CHAR),
         profit_center_name VARCHAR2 (30 CHAR),trade_date VARCHAR2 (15 CHAR),trader VARCHAR2 (15 CHAR),deal_type VARCHAR2 (30 CHAR),instrument VARCHAR2 (30 CHAR),
        external_ref_no VARCHAR2 (30 CHAR),fx_rate NUMBER(25,10));



----------------------------------------------------------------------------------------------------

  
			