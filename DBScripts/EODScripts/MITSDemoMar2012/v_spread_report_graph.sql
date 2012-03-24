CREATE OR REPLACE VIEW V_SPREAD_REPORT_GRAPH AS
WITH vsp_data AS
        (SELECT *
           FROM v_spread_report)
   SELECT   corporate_id, instrument_id, instrument_name, month_display,
            TO_NUMBER (month_order) month_order, SUM (day_1) day_1,
            SUM (day_2) day_2, SUM (day_3) day_3, SUM (day_4) day_4,
            SUM (day_5) day_5, SUM (day_6) day_6, SUM (day_7) day_7,
            SUM (day_8) day_8, SUM (day_9) day_9, MAX (day_1_name) day_1_name,
            MAX (day_2_name) day_2_name, MAX (day_3_name) day_3_name,
            MAX (day_4_name) day_4_name, MAX (day_5_name) day_5_name,
            MAX (day_6_name) day_6_name, MAX (day_7_name) day_7_name,
            MAX (day_8_name) day_8_name, MAX (day_9_name) day_9_name
       FROM (SELECT vsp.corporate_id, vsp.instrument_id, vsp.instrument_name,
                    TO_CHAR (ADD_MONTHS (SYSDATE, ((temp.ss +1) - 1)),
                             'Mon-yyyy'
                            ) month_display,
                    TO_CHAR (ADD_MONTHS (SYSDATE, ((temp.ss +1) - 1)),
                             'yyyymm'
                            ) month_order,
                    (CASE
                        WHEN vsp.dispay_order = 1
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_1,
                    (CASE
                        WHEN vsp.dispay_order = 2
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_2,
                    (CASE
                        WHEN vsp.dispay_order = 3
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_3,
                    (CASE
                        WHEN vsp.dispay_order = 4
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_4,
                    (CASE
                        WHEN vsp.dispay_order = 5
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_5,
                    (CASE
                        WHEN vsp.dispay_order = 6
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_6,
                    (CASE
                        WHEN vsp.dispay_order = 7
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_7,
                    (CASE
                        WHEN vsp.dispay_order = 8
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_8,
                    (CASE
                        WHEN vsp.dispay_order = 9
                           THEN (CASE
                                    WHEN temp.ss = 1
                                       THEN spread_month_1_quote
                                    WHEN temp.ss = 2
                                       THEN spread_month_2_quote
                                    WHEN temp.ss = 3
                                       THEN spread_month_3_quote
                                    WHEN temp.ss = 4
                                       THEN spread_month_4_quote
                                    WHEN temp.ss = 5
                                       THEN spread_month_5_quote
                                    WHEN temp.ss = 6
                                       THEN spread_month_6_quote
                                    WHEN temp.ss = 7
                                       THEN spread_month_7_quote
                                    WHEN temp.ss = 8
                                       THEN spread_month_8_quote
                                    WHEN temp.ss = 9
                                       THEN spread_month_9_quote
                                    WHEN temp.ss = 10
                                       THEN spread_month_10_quote
                                    WHEN temp.ss = 11
                                       THEN spread_month_11_quote
                                    WHEN temp.ss = 12
                                       THEN spread_month_12_quote
                                    ELSE 0
                                 END
                                )
                        ELSE 0
                     END
                    ) day_9,
                    (CASE
                        WHEN vsp.dispay_order = 1
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_1_name,
                    (CASE
                        WHEN vsp.dispay_order = 2
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_2_name,
                    (CASE
                        WHEN vsp.dispay_order = 3
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_3_name,
                    (CASE
                        WHEN vsp.dispay_order = 4
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_4_name,
                    (CASE
                        WHEN vsp.dispay_order = 5
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_5_name,
                    (CASE
                        WHEN vsp.dispay_order = 6
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_6_name,
                    (CASE
                        WHEN vsp.dispay_order = 7
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_7_name,
                    (CASE
                        WHEN vsp.dispay_order = 8
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_8_name,
                    (CASE
                        WHEN vsp.dispay_order = 9
                           THEN TO_CHAR (vsp.work_day, 'dd-Mon-yyyy')
                        ELSE NULL
                     END
                    ) day_9_name
               FROM vsp_data vsp,
                    (SELECT ROWNUM ss
                       FROM user_objects
                      WHERE ROWNUM <= 12) temp)
   GROUP BY corporate_id,
            instrument_id,
            instrument_name,
            month_display,
            month_order 
