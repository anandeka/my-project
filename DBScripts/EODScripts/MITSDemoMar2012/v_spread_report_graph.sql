create or replace view v_spread_report_graph as
with vsp_data as (select * from v_spread_report)
select corporate_id,
       instrument_id,
       instrument_name,
       month_display,
       to_number(month_order)month_order,
       sum(day_1)day_1,
       sum(day_2)day_2,
       sum(day_3)day_3,
       sum(day_4)day_4,
       sum(day_5)day_5,
       sum(day_6)day_6,
       sum(day_7)day_7,
       sum(day_8)day_8,
       sum(day_9)day_9,                                                        
       max(day_1_name)day_1_name,
       max(day_2_name)day_2_name,
       max(day_3_name)day_3_name,
       max(day_4_name)day_4_name,
       max(day_5_name)day_5_name,
       max(day_6_name)day_6_name,
       max(day_7_name)day_7_name,
       max(day_8_name)day_8_name,
       max(day_9_name)day_9_name
from(       
select vsp.corporate_id,
       vsp.instrument_id,
       vsp.instrument_name,
       to_char(add_months(sysdate, (temp.ss - 1)), 'Mon-yyyy') month_display,
       to_char(add_months(sysdate, (temp.ss - 1)), 'yyyymm') month_order,
       (case
         when vsp.dispay_order = 1 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_1,
       (case
         when vsp.dispay_order = 2 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_2,
       (case
         when vsp.dispay_order = 3 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_3,
       (case
         when vsp.dispay_order = 4 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_4,
       (case
         when vsp.dispay_order = 5 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_5,
       (case
         when vsp.dispay_order = 6 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_6,
       (case
         when vsp.dispay_order = 7 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_7,
       (case
         when vsp.dispay_order = 8 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_8,
       (case
         when vsp.dispay_order = 9 then
          (case
         when temp.ss = 1 then
          spread_month_1_quote
         when temp.ss = 2 then
          spread_month_2_quote
         when temp.ss = 3 then
          spread_month_3_quote
         when temp.ss = 4 then
          spread_month_4_quote
         when temp.ss = 5 then
          spread_month_5_quote
         when temp.ss = 6 then
          spread_month_6_quote
         when temp.ss = 7 then
          spread_month_7_quote
         when temp.ss = 8 then
          spread_month_8_quote
         when temp.ss = 9 then
          spread_month_9_quote
         when temp.ss = 10 then
          spread_month_10_quote
         when temp.ss = 11 then
          spread_month_11_quote
         when temp.ss = 12 then
          spread_month_12_quote
         else
          0
       end) else 0 end) day_9,
       (case
         when vsp.dispay_order = 1 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_1_name,
       (case
         when vsp.dispay_order = 2 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_2_name,   
          (case
         when vsp.dispay_order = 3 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_3_name,   
          (case
         when vsp.dispay_order = 4 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_4_name, 
          (case
         when vsp.dispay_order = 5 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_5_name,
          (case
         when vsp.dispay_order = 6 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_6_name,
          (case
         when vsp.dispay_order = 7 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_7_name,
          (case
         when vsp.dispay_order = 8 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_8_name, 
         (case
         when vsp.dispay_order = 9 then
              to_char(vsp.work_day,'dd-Mon-yyyy')
          else
          null end)day_9_name           
  from vsp_data vsp,
       (select rownum ss from user_objects where rownum <= 12) temp)
       WHERE corporate_id = 'EKA' and instrument_id = 'DIM-10'
group by corporate_id,
       instrument_id,
       instrument_name,
       month_display,
       month_order
