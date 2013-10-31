create or replace view v_rpt_dim_pricing_days as
select tmp.instrument_id,
       tmp.instrument_name,
       tmp.year_1 year_name,
       'Jan' month_1,
       'Feb' month_2,
       'Mar' month_3,
       'Apr' month_4,
       'May' month_5,
       'Jun' month_6,
       'Jul' month_7,
       'Aug' month_8,
       'Sep' month_9,
       'Oct' month_10,
       'Nov' month_11,
       'Dec' month_12,
      sum( case when tmp.sno=1 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_1,
       sum( case when tmp.sno=2 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_2,
       sum( case when tmp.sno=3 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_3,
      sum( case when tmp.sno=4 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_4,
       sum( case when tmp.sno=5 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_5,
       sum( case when tmp.sno=6 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_6,
       sum( case when tmp.sno=7 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_7,
       sum( case when tmp.sno=8 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_8,
       sum( case when tmp.sno=9 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_9,
       sum( case when tmp.sno=10 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_10,
       sum( case when tmp.sno=11 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_11,
       sum( case when tmp.sno=12 then
            tmp.no_of_days
            else
            0 end) no_of_days_month_12
from
(select dim.instrument_id,
       dim.instrument_name,
       tt.sno,
       tt1.year_1,
       to_date('01-' || tt.sno || '-' || tt1.year_1, 'dd-mm-yyyy') start_date,
       last_day(to_date('01-' || tt.sno || '-' || tt1.year_1, 'dd-mm-yyyy')) end_date,
       f_get_pricing_days(dim.instrument_id,
                          to_date('01-' || tt.sno || '-' || tt1.year_1,
                                  'dd-mm-yyyy'),
                          last_day(to_date('01-' || tt.sno || '-' ||
                                           tt1.year_1,
                                           'dd-mm-yyyy'))) no_of_days
  from dim_der_instrument_master dim,
       irm_instrument_type_master irm,
       (select rownum sno,
               2011   year_1
          from user_tables
         where rownum < 13) tt,
   (select 2007+rownum year_1
          from user_tables
         where rownum < 11) tt1
 where dim.instrument_type_id = irm.instrument_type_id
   and irm.instrument_type = 'Future'
   and dim.is_active = 'Y'
   and dim.is_deleted = 'N')tmp
   group by tmp.instrument_id,
       tmp.instrument_name,tmp.year_1
/