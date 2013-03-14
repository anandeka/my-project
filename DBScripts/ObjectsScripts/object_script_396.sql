/*
As a part of Projected Price Exposure Tuning issue
*/
create or replace type type_prc_mth_strt_dt as object(
    pcbpd_id varchar2(30),
    poch_id varchar2(30),
    start_date  date,
    end_date date
);
/

create or replace type type_tbl_prc_mth_strt_dt is table of type_prc_mth_strt_dt;
/

create index dieqd_idx1 on di_del_item_exp_qp_details(pcdi_id,pcbpd_id);