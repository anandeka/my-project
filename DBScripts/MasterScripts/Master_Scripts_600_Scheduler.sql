-- Default Scripts for Pricing process Scheduler
-- This script is a temp. script which is not required when UI is build for Scheduler.
--QEP
INSERT INTO sid_schedule_input_dts
     VALUES (1, SYSTIMESTAMP, 'NET', NULL, NULL, 'DAILY', 'ED', NULL,
             'AK-161', SYSTIMESTAMP, 'Y');

INSERT INTO sd_scheduler_dts
            (sd_id, sid_id, cron_exp, execution_cnt, status
            )
     VALUES ('1', '1', '0 0/2 * 1/1 * ? *', 0, 'Active'
            );

INSERT INTO jd_job_details
            (job_id, job_type,
             job_criteria,
             corporate_id
            )
     VALUES ('1', 'QEP',
             '{
  "asOfDate": "29-May-2013",
  "corporateId": "BLD",
  "isAnyDayPricing": true,
  "isAveragePricing": true
}',
             'BLD'
            );



INSERT INTO sjd_scheduler_job_details
            (sjd_id, sd_id, job_id, is_active
            )
     VALUES ('1', '1', '1', 'Y'
            );


-- FEP

INSERT INTO jd_job_details
            (job_id, job_type,
             job_criteria,
             corporate_id
            )
     VALUES ('2', 'FEP',
             '{
  "asOfDate": "29-May-2013",
  "corporateId": "BLD",
  "priceProcessType": "FEP",
  "isScheduled": true
}',
             'BLD'
            );


INSERT INTO sid_schedule_input_dts
            (sid_id, start_time, end_type, end_time, end_no_occu,
             reoccurence_type, reoccur_pattern, reoccur_pattern_val,
             created_by, created_date, is_active
            )
     VALUES ('2', SYSTIMESTAMP, 'NET', NULL, NULL,
             'DAILY', 'ED', NULL,
             'AK-161', SYSTIMESTAMP, 'Y'
            );



INSERT INTO sd_scheduler_dts
            (sd_id, sid_id, cron_exp, execution_cnt, status
            )
     VALUES ('2', '2', '0 45 12 1/1 * ? 2013', 0, 'Active'
            );


INSERT INTO sjd_scheduler_job_details
            (sjd_id, sd_id, job_id, is_active
            )
     VALUES ('2', '2', '2', 'Y'
            );


-- Average pricing process
INSERT INTO jd_job_details
            (job_id, job_type,
             job_criteria,
             corporate_id
            )
     VALUES ('3', 'AVG_PP',
             '{
  "asOfDate": "25-May-2013",
  "corporateId": "BLD",
  "priceProcessType": "AVG_PP",
  "isScheduled": true
}',
             'BLD'
            );


INSERT INTO sid_schedule_input_dts
            (sid_id, start_time, end_type, end_time, end_no_occu,
             reoccurence_type, reoccur_pattern, reoccur_pattern_val,
             created_by, created_date, is_active
            )
     VALUES ('3', SYSTIMESTAMP, 'NET', NULL, NULL,
             'DAILY', 'ED', NULL,
             'AK-161', SYSTIMESTAMP, 'Y'
            );



INSERT INTO sd_scheduler_dts
            (sd_id, sid_id, cron_exp, execution_cnt, status
            )
     VALUES ('3', '3', '0 45 12 1/1 * ? 2013', 0, 'Active'
            );


INSERT INTO sjd_scheduler_job_details
            (sjd_id, sd_id, job_id, is_active
            )
     VALUES ('3', '3', '3', 'Y'
            );