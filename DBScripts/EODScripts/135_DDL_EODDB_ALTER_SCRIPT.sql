DROP INDEX IDX_DIQD;

CREATE INDEX IDX_DIQS2 ON DIQS_DELIVERY_ITEM_QTY_STATUS(PROCESS_ID,IS_ACTIVE);

CREATE INDEX IDX_POCH1 ON POCH_PRICE_OPT_CALL_OFF_HEADER(IS_ACTIVE,PCDI_ID);

CREATE INDEX IDX_DI2 ON DI_DEL_ITEM_EXP_QP_DETAILS(IS_ACTIVE,PCDI_ID);

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD GMR_QTY_UNIT_ID VARCHAR2(15);

ALTER TABLE DGRD_DELIVERED_GRD ADD GMR_QTY_UNIT_ID VARCHAR2(15);

ALTER TABLE GRD_GOODS_RECORD_DETAIL ADD (COT_INT_ACTION_REF_NO  VARCHAR2(30));
ALTER  TABLE GRDL_GOODS_RECORD_DETAIL_LOG ADD (COT_INT_ACTION_REF_NO  VARCHAR2(30));

ALTER TABLE TEMP_MAS ADD(
INTERNAL_GMR_REF_NO         VARCHAR2(15),
GMR_REF_NO                  VARCHAR2(30));

ALTER TABLE PATD_PA_TEMP_DATA ADD(
WAREHOUSE_PROFILE_ID VARCHAR2(15),
WAREHOUSE_NAME VARCHAR2(100));

ALTER TABLE PA_TEMP ADD(
WAREHOUSE_PROFILE_ID VARCHAR2(15),
WAREHOUSE_NAME VARCHAR2(100));

ALTER TABLE GEPD_GMR_ELEMENT_PLEDGE_DETAIL ADD(
PLEDGE_INPUT_GMR_WH_PROFILE_ID VARCHAR2(15),
PLEDGE_INPUT_GMR_WH_NAME VARCHAR2(100));

ALTER TABLE PA_PURCHASE_ACCURAL ADD(
WAREHOUSE_PROFILE_ID VARCHAR2(15),
WAREHOUSE_NAME VARCHAR2(100));

ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG ADD PROCESS VARCHAR2(3);
ALTER TABLE SPQL_STOCK_PAYABLE_QTY_LOG ADD PROCESS VARCHAR2(3);

declare
  cursor c1 is
    select * from dbd_database_dump;
begin
  for c11 in c1
  loop
    update grdl_goods_record_detail_log grdl
       set grdl.process = c11.process
     where grdl.dbd_id = c11.dbd_id;
    update spql_stock_payable_qty_log grdl
       set grdl.process = c11.process
     where grdl.dbd_id = c11.dbd_id;
  end loop;
end;
/
CREATE TABLE CQPD_CONTRACT_QP_DETAIL (
CORPORATE_ID                           VARCHAR2(15),
PCDI_ID                                VARCHAR2(15),
INTERNAL_CONTRACT_ITEM_REF_NO          VARCHAR2(15),
QP_START_DATE                          DATE,
QP_END_DATE                            DATE);

CREATE INDEX IDX_CQPD1 ON CQPD_CONTRACT_QP_DETAIL(CORPORATE_ID);

CREATE TABLE GTHUL_GMR_TREATMENT_HEADER_UL(
GTHUL_ID                VARCHAR2(15),
GTH_ID                  VARCHAR2(15),
ENTRY_TYPE              VARCHAR2(30),
INTERNAL_GMR_REF_NO     VARCHAR2(15),
PCDI_ID                 VARCHAR2(15),
PCTH_ID                 VARCHAR2(15),
INTERNAL_ACTION_REF_NO  VARCHAR2(15),
IS_ACTIVE               VARCHAR2(1),
PROCESS                 VARCHAR2(3),
DBD_ID                  VARCHAR2(15));

CREATE TABLE GRHUL_GMR_REFINING_HEADER_UL(
GRHUL_ID                VARCHAR2(15),
GRH_ID                  VARCHAR2(15),
ENTRY_TYPE              VARCHAR2(30),
INTERNAL_GMR_REF_NO     VARCHAR2(15),
PCDI_ID                 VARCHAR2(15),
PCRH_ID                 VARCHAR2(15),
INTERNAL_ACTION_REF_NO  VARCHAR2(15),
IS_ACTIVE              VARCHAR2(1),
PROCESS                 VARCHAR2(3),
DBD_ID                  VARCHAR2(15));

CREATE TABLE GPHUL_GMR_PENALTY_HEADER_UL(
GPHUL_ID                VARCHAR2(15),
GPH_ID                  VARCHAR2(15),
ENTRY_TYPE              VARCHAR2(30),
INTERNAL_GMR_REF_NO     VARCHAR2(15),
PCDI_ID                 VARCHAR2(15),
PCAPH_ID                VARCHAR2(15),
INTERNAL_ACTION_REF_NO  VARCHAR2(15),
IS_ACTIVE              VARCHAR2(1),
PROCESS                 VARCHAR2(3),
DBD_ID                  VARCHAR2(15));

DROP MATERIALIZED VIEW GTH_GMR_TREATMENT_HEADER;
DROP MATERIALIZED VIEW GPH_GMR_PENALTY_HEADER;
DROP MATERIALIZED VIEW GRH_GMR_REFINING_HEADER;

DROP TABLE GTH_GMR_TREATMENT_HEADER;
DROP TABLE GPH_GMR_PENALTY_HEADER;
DROP TABLE GRH_GMR_REFINING_HEADER;

CREATE TABLE GTH_GMR_TREATMENT_HEADER(
GTH_ID                  VARCHAR2(15 CHAR)     NOT NULL,
INTERNAL_GMR_REF_NO     VARCHAR2(15 CHAR)     NOT NULL,
PCDI_ID                 VARCHAR2(15 CHAR)     NOT NULL,
PCTH_ID                 VARCHAR2(15 CHAR)     NOT NULL,
IS_ACTIVE               CHAR(1 CHAR)          DEFAULT 'Y' NOT NULL,
INTERNAL_ACTION_REF_NO  VARCHAR2(15 CHAR),
DBD_ID                    VARCHAR2(15),
PROCESS_ID                VARCHAR2(15));

CREATE TABLE GRH_GMR_REFINING_HEADER(
GRH_ID                  VARCHAR2(15 CHAR)     NOT NULL,
INTERNAL_GMR_REF_NO     VARCHAR2(15 CHAR)     NOT NULL,
PCDI_ID                 VARCHAR2(15 CHAR)     NOT NULL,
PCRH_ID                 VARCHAR2(15 CHAR)     NOT NULL,
IS_ACTIVE               CHAR(1 CHAR)          DEFAULT 'Y'  NOT NULL,
INTERNAL_ACTION_REF_NO  VARCHAR2(15 CHAR),
DBD_ID                    VARCHAR2(15),
PROCESS_ID                VARCHAR2(15));

CREATE TABLE GPH_GMR_PENALTY_HEADER(
GPH_ID                  VARCHAR2(15 CHAR)     NOT NULL,
INTERNAL_GMR_REF_NO     VARCHAR2(15 CHAR)     NOT NULL,
PCDI_ID                 VARCHAR2(15 CHAR)     NOT NULL,
PCAPH_ID                VARCHAR2(15 CHAR)     NOT NULL,
IS_ACTIVE               CHAR(1 CHAR)          DEFAULT 'Y' NOT NULL,
INTERNAL_ACTION_REF_NO  VARCHAR2(15 CHAR),
DBD_ID                    VARCHAR2(15),
PROCESS_ID                VARCHAR2(15));

begin
for cc in (select * from dbd_database_dump) loop
insert into gthul_gmr_treatment_header_ul
      (gthul_id,
       gth_id,
       entry_type,
       internal_gmr_ref_no,
       pcdi_id,
       pcth_id,
       internal_action_ref_no,
       is_active,
       process,
       dbd_id)
      select ul.gthul_id,
             ul.gth_id,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.pcdi_id,
             ul.pcth_id,
             ul.internal_action_ref_no,
             ul.is_active,
             cc.process,
             cc.dbd_id
        from gthul_gmr_treatment_header_ul@eka_appdb ul,
             axs_action_summary@eka_appdb            axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = cc.corporate_id
         and axs.created_date > cc.start_date
         and axs.created_date <= cc.end_date;
    commit;
    insert into grhul_gmr_refining_header_ul
      (grhul_id,
       grh_id,
       entry_type,
       internal_gmr_ref_no,
       pcdi_id,
       pcrh_id,
       internal_action_ref_no,
       is_active,
       process,
       dbd_id)
      select ul.grhul_id,
             ul.grh_id,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.pcdi_id,
             ul.pcrh_id,
             ul.internal_action_ref_no,
             ul.is_active,
             cc.process,
             cc.dbd_id
        from grhul_gmr_refining_header_ul@eka_appdb ul,
             axs_action_summary@eka_appdb           axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = cc.corporate_id
         and axs.created_date > cc.start_date
         and axs.created_date <= cc.end_date;
    commit;
    insert into gphul_gmr_penalty_header_ul
      (gphul_id,
       gph_id,
       entry_type,
       internal_gmr_ref_no,
       pcdi_id,
       pcaph_id,
       internal_action_ref_no,
       is_active,
       process,
       dbd_id)
      select ul.gphul_id,
             ul.gph_id,
             ul.entry_type,
             ul.internal_gmr_ref_no,
             ul.pcdi_id,
             ul.pcaph_id,
             ul.internal_action_ref_no,
             ul.is_active,
             cc.process,
             cc.dbd_id
        from gphul_gmr_penalty_header_ul@eka_appdb ul,
             axs_action_summary@eka_appdb          axs
       where ul.internal_action_ref_no = axs.internal_action_ref_no
         and axs.corporate_id = cc.corporate_id
         and axs.created_date > cc.start_date
         and axs.created_date <= cc.end_date;
end loop;         
end;
/
