create or replace view v_spread_report as 
select corporate_id,
       instrument_id,
       instrument_name,
       work_day,
       dispay_order,
       month_1_quote - date_3m spread_month_1_quote,
       month_2_quote - date_3m spread_month_2_quote,
       month_3_quote - date_3m spread_month_3_quote,
       month_4_quote - date_3m spread_month_4_quote,
       month_5_quote - date_3m spread_month_5_quote,
       month_6_quote - date_3m spread_month_6_quote,
       month_7_quote - date_3m spread_month_7_quote,
       month_8_quote - date_3m spread_month_8_quote,
       month_9_quote - date_3m spread_month_9_quote,
       month_10_quote - date_3m spread_month_10_quote,
       month_11_quote - date_3m spread_month_11_quote,
       month_12_quote - date_3m spread_month_12_quote,
       date_cash - date_3m date_cash,
       date_3m date_3m,
       month_1_name,
       month_2_name,
       month_3_name,
       month_4_name,
       month_5_name,
       month_6_name,
       month_7_name,
       month_8_name,
       month_9_name,
       month_10_name,
       month_11_name,
       month_12_name
  from (select corporate_id,
               third_wed.instrument_id,
               third_wed.instrument_name,
               nine_days.work_day,
               nine_days.dispay_order,
               f_get_quote_cash_3m(corporate_id,
                                   nine_days.work_day,
                                   third_wed.instrument_id,
                                   'PP-9') date_cash,
               f_get_quote_cash_3m(corporate_id,nine_days.work_day,
                                   third_wed.instrument_id,
                                   'PP-8') date_3m,
               f_get_quote_3rd_wed(corporate_id,month_1_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_1_quote,
               f_get_quote_3rd_wed(corporate_id,month_2_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_2_quote,
               f_get_quote_3rd_wed(corporate_id,month_3_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_3_quote,
               f_get_quote_3rd_wed(corporate_id,month_4_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_4_quote,
               f_get_quote_3rd_wed(corporate_id,month_5_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_5_quote,
               f_get_quote_3rd_wed(corporate_id,month_6_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_6_quote,
               f_get_quote_3rd_wed(corporate_id,month_7_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_7_quote,
               f_get_quote_3rd_wed(corporate_id,month_8_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_8_quote,
               f_get_quote_3rd_wed(corporate_id,month_9_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_9_quote,
               f_get_quote_3rd_wed(corporate_id,month_10_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_10_quote,
               f_get_quote_3rd_wed(corporate_id,month_11_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_11_quote,
               f_get_quote_3rd_wed(corporate_id,month_12_date,
                                   nine_days.work_day,
                                   third_wed.instrument_id) month_12_quote,
               third_wed.month_1_name,
               third_wed.month_2_name,
               third_wed.month_3_name,
               third_wed.month_4_name,
               third_wed.month_5_name,
               third_wed.month_6_name,
               third_wed.month_7_name,
               third_wed.month_8_name,
               third_wed.month_9_name,
               third_wed.month_10_name,
               third_wed.month_11_name,
               third_wed.month_12_name
          from (select akc.corporate_id,
                       dim.instrument_id,
                       dim.instrument_name,
                       f_get_next_day_working(add_months(sysdate, 1),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_1_date,
                       f_get_next_day_working(add_months(sysdate, 2),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_2_date,
                       f_get_next_day_working(add_months(sysdate, 3),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_3_date,
                       f_get_next_day_working(add_months(sysdate, 4),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_4_date,
                       f_get_next_day_working(add_months(sysdate, 5),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_5_date,
                       f_get_next_day_working(add_months(sysdate, 6),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_6_date,
                       f_get_next_day_working(add_months(sysdate, 7),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_7_date,
                       f_get_next_day_working(add_months(sysdate, 8),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_8_date,
                       f_get_next_day_working(add_months(sysdate, 9),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_9_date,
                       f_get_next_day_working(add_months(sysdate, 10),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_10_date,
                       f_get_next_day_working(add_months(sysdate, 11),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_11_date,
                       f_get_next_day_working(add_months(sysdate, 12),
                                              'Wed',
                                              3,
                                              dim.instrument_id) month_12_date,
                       to_char(sysdate, 'Mon-YYYY') month_1_name,
                       to_char(add_months(sysdate, 1), 'Mon-YYYY') month_2_name,
                       to_char(add_months(sysdate, 2), 'Mon-YYYY') month_3_name,
                       to_char(add_months(sysdate, 3), 'Mon-YYYY') month_4_name,
                       to_char(add_months(sysdate, 4), 'Mon-YYYY') month_5_name,
                       to_char(add_months(sysdate, 5), 'Mon-YYYY') month_6_name,
                       to_char(add_months(sysdate, 6), 'Mon-YYYY') month_7_name,
                       to_char(add_months(sysdate, 7), 'Mon-YYYY') month_8_name,
                       to_char(add_months(sysdate, 8), 'Mon-YYYY') month_9_name,
                       to_char(add_months(sysdate, 9), 'Mon-YYYY') month_10_name,
                       to_char(add_months(sysdate, 10), 'Mon-YYYY') month_11_name,
                       to_char(add_months(sysdate, 11), 'Mon-YYYY') month_12_name
                  from dim_der_instrument_master  dim,
                       pdd_product_derivative_def pdd,
                       emt_exchangemaster         emt,
                       irm_instrument_type_master irm,
                       ak_corporate akc
                 where emt.exchange_id = pdd.exchange_id
                   and pdd.derivative_def_id = dim.product_derivative_id
                   and emt.exchange_code = 'LME'
                   and irm.instrument_type_id = dim.instrument_type_id
                   and irm.instrument_type = 'Future'
                  and akc.corporate_id <> 'EKA-SYS'
                   ) third_wed,
               v_cdc_instrument_days nine_days
         where third_wed.instrument_id = nine_days.instrument_id) ttt;
